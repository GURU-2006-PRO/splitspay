import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../models/group_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'split_confirmation_screen.dart';

class SelectParticipantsWithUnitsScreen extends StatefulWidget {
  final Map<String, dynamic> paymentData;

  const SelectParticipantsWithUnitsScreen({
    Key? key,
    required this.paymentData,
  }) : super(key: key);

  @override
  State<SelectParticipantsWithUnitsScreen> createState() => _SelectParticipantsWithUnitsScreenState();
}

class _SelectParticipantsWithUnitsScreenState extends State<SelectParticipantsWithUnitsScreen> {
  final Map<String, double> _participantUnits = {}; // userId -> consumption unit
  final List<double> _quickUnits = [0.5, 0.7, 1.0, 1.2, 1.5];

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final group = groupProvider.selectedGroup;

    if (group == null) {
      return const Scaffold(
        body: Center(child: Text('No group selected')),
      );
    }

    final totalAmount = widget.paymentData['amount'] as double;
    final totalUnits = _participantUnits.values.fold(0.0, (sum, unit) => sum + unit);
    final selectedCount = _participantUnits.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Who Participated?'),
      ),
      body: Column(
        children: [
          // Bill Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
            ),
            child: Column(
              children: [
                Text(
                  widget.paymentData['merchantName'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  Helpers.formatCurrency(totalAmount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$selectedCount participants • $totalUnits total units',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.primaryLight.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Select members and set consumption units (1.0 = full, 0.5 = half, etc.)',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          // Member List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: group.allMembers.length,
              itemBuilder: (context, index) {
                final member = group.allMembers[index];
                final isSelected = _participantUnits.containsKey(member.userId);
                final currentUnit = _participantUnits[member.userId] ?? 1.0;

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  color: isSelected ? AppColors.primaryLight.withOpacity(0.1) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        // Member Row
                        Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _participantUnits[member.userId] = member.consumptionWeight ?? 1.0;
                                  } else {
                                    _participantUnits.remove(member.userId);
                                  }
                                });
                              },
                            ),
                            CircleAvatar(
                              backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                              child: Text(member.userName[0].toUpperCase()),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.userName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Balance: ${Helpers.formatCurrency(member.balance)}',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: Text(
                                  '${currentUnit.toStringAsFixed(1)} unit',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Unit Selector (shown when selected)
                        if (isSelected) ...[
                          const SizedBox(height: AppSpacing.sm),
                          const Divider(height: 1),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              const Text('Consumption:', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Wrap(
                                  spacing: AppSpacing.xs,
                                  children: _quickUnits.map((unit) {
                                    final isActive = currentUnit == unit;
                                    return ChoiceChip(
                                      label: Text(unit.toStringAsFixed(1)),
                                      selected: isActive,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() {
                                            _participantUnits[member.userId] = unit;
                                          });
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showCustomUnitDialog(member),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedCount > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Per Unit Cost:', style: TextStyle(fontSize: 14)),
                        Text(
                          Helpers.formatCurrency(totalUnits > 0 ? totalAmount / totalUnits : 0),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedCount > 0
                          ? () => _proceedToSplit(group)
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        selectedCount > 0
                            ? 'Calculate Split ($selectedCount participants)'
                            : 'Select at least one participant',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomUnitDialog(Member member) {
    final controller = TextEditingController(
      text: (_participantUnits[member.userId] ?? 1.0).toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Unit for ${member.userName}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Consumption Unit',
            hintText: '1.0',
            helperText: '1.0 = full portion, 0.5 = half, etc.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                setState(() {
                  _participantUnits[member.userId] = value;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  void _proceedToSplit(Group group) {
    // Calculate splits
    final totalAmount = widget.paymentData['amount'] as double;
    final totalUnits = _participantUnits.values.fold(0.0, (sum, unit) => sum + unit);
    
    if (totalUnits == 0) return;

    final perUnitCost = totalAmount / totalUnits;
    final Map<String, Map<String, dynamic>> splits = {};
    
    double calculatedTotal = 0;
    String? lastMemberId;

    // First pass: Calculate raw amounts
    for (var entry in _participantUnits.entries) {
      final member = group.allMembers.firstWhere((m) => m.userId == entry.key);
      final unit = entry.value;
      
      // Round to 2 decimal places
      double amount = double.parse((perUnitCost * unit).toStringAsFixed(2));
      calculatedTotal += amount;
      lastMemberId = entry.key;
      
      splits[entry.key] = {
        'member': member,
        'unit': unit,
        'amount': amount,
      };
    }

    // Adjust for rounding errors (add/subtract difference from last person)
    if (lastMemberId != null) {
      final diff = totalAmount - calculatedTotal;
      if (diff.abs() > 0.001) {
        final currentAmount = splits[lastMemberId]!['amount'] as double;
        splits[lastMemberId]!['amount'] = double.parse((currentAmount + diff).toStringAsFixed(2));
      }
    }

    // Navigate to confirmation screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SplitConfirmationScreen(
          paymentData: widget.paymentData,
          splits: splits,
          totalUnits: totalUnits,
        ),
      ),
    );
  }
}
