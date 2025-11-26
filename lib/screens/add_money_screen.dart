import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../models/group_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({Key? key}) : super(key: key);

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final List<int> _quickAmounts = [500, 1000, 2000, 5000, 10000];
  Member? _selectedMember;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addMoney() async {
    if (_selectedMember == null) {
      Helpers.showErrorSnackBar(context, 'Please select a member');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      Helpers.showErrorSnackBar(context, 'Please enter a valid amount');
      return;
    }

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final group = groupProvider.selectedGroup;

    if (group == null) return;

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Adding money...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Add contribution to database for selected member
      await groupProvider.addContribution(group.id, _selectedMember!.userId, amount);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show success message
      Helpers.showSuccessSnackBar(
        context,
        '${Helpers.formatCurrency(amount)} added for ${_selectedMember!.userName}',
      );

      // Clear amount field and reset for next entry
      setState(() {
        _amountController.clear();
        // Keep member selected or move to next
      });

      // Refresh the group data
      await groupProvider.refreshGroup(group.id);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      Helpers.showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final group = groupProvider.selectedGroup;
    final user = authProvider.currentUser;

    if (group == null || user == null) {
      return const Scaffold(
        body: Center(child: Text('No group selected')),
      );
    }

    // Auto-select current user if not selected
    if (_selectedMember == null && group.allMembers.isNotEmpty) {
      _selectedMember = group.allMembers.firstWhere(
        (m) => m.userId == user.id,
        orElse: () => group.allMembers.first,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Money to Pool'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Info Card
            Card(
              color: AppColors.primaryLight.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        group.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(group.name, style: AppTextStyles.headline3),
                          Text(
                            'Total Pool: ${Helpers.formatCurrency(group.totalBalance)}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Select Member
            const Text('Select Member', style: AppTextStyles.headline3),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group members by family and display
                    ...group.families.expand((family) {
                      return [
                        // Family header
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
                          child: Row(
                            children: [
                              Icon(
                                family.name == 'Family' ? Icons.family_restroom :
                                family.name == 'Couple' ? Icons.favorite :
                                family.name == 'Children' ? Icons.child_care :
                                Icons.person,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                family.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Members in this family
                        ...family.members.map((member) {
                          return RadioListTile<Member>(
                            value: member,
                            groupValue: _selectedMember,
                            onChanged: (Member? value) {
                              setState(() {
                                _selectedMember = value;
                              });
                            },
                            contentPadding: const EdgeInsets.only(left: 16),
                            title: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                                  child: Text(
                                    member.userName[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(member.userName),
                                      Text(
                                        'Balance: ${Helpers.formatCurrency(member.balance)}',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ];
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Amount Input
            const Text('Enter Amount', style: AppTextStyles.headline3),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Quick Amount Buttons
            const Text('Quick Add', style: AppTextStyles.body2),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _quickAmounts.map((amount) {
                return OutlinedButton(
                  onPressed: () {
                    _amountController.text = amount.toString();
                    setState(() {});
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('₹$amount'),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Info Box
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _selectedMember != null && _selectedMember!.userId == user.id
                          ? 'Adding money to your own balance in the shared pool.'
                          : 'Adding money on behalf of ${_selectedMember?.userName ?? "member"}. Use this when collecting cash from group members.',
                      style: const TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Add Money Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedMember != null &&
                        _amountController.text.isNotEmpty &&
                        (double.tryParse(_amountController.text) ?? 0) > 0
                    ? _addMoney
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _amountController.text.isNotEmpty && _selectedMember != null
                      ? 'Add ${Helpers.formatCurrency(double.tryParse(_amountController.text) ?? 0)}'
                      : 'Add Money',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Continue adding hint
            Center(
              child: Text(
                'After adding, you can select another member to continue',
                style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
