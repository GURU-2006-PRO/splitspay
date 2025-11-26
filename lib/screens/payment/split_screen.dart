import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/group_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../services/splitting_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import 'payment_success_screen.dart';

class SplitScreen extends StatefulWidget {
  final double amount;
  final String description;
  final List<String> selectedUserIds;

  const SplitScreen({
    Key? key,
    required this.amount,
    required this.description,
    required this.selectedUserIds,
  }) : super(key: key);

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  final SplittingService _splittingService = SplittingService();
  String _splitMode = 'equal'; // 'equal' or 'custom'
  Map<String, double> _customRatios = {}; // UserId -> Percentage
  Map<String, double> _calculatedAmounts = {};
  bool _isValid = true;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _calculateEqualSplit();
  }

  void _calculateEqualSplit() {
    setState(() {
      _calculatedAmounts = _splittingService.calculateEqualSplit(
        widget.amount,
        widget.selectedUserIds,
      );
      _isValid = true;
      _validationError = null;
    });
  }

  void _calculateCustomSplit() {
    double totalRatio = _customRatios.values.fold(0, (sum, val) => sum + val);
    
    if ((totalRatio - 100).abs() > 0.1) {
      setState(() {
        _isValid = false;
        _validationError = 'Total must be 100% (Current: ${totalRatio.toStringAsFixed(1)}%)';
      });
      return;
    }

    setState(() {
      _calculatedAmounts = _splittingService.calculateCustomSplit(
        widget.amount,
        _customRatios,
      );
      _isValid = true;
      _validationError = null;
    });
  }

  void _onRatioChanged(String userId, String value) {
    final ratio = double.tryParse(value) ?? 0;
    _customRatios[userId] = ratio;
    _calculateCustomSplit();
  }

  Future<void> _processPayment() async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final group = groupProvider.selectedGroup;
    final user = authProvider.currentUser;

    if (group == null || user == null) return;

    // Validate balances
    final participants = <Participant>[];
    bool insufficientBalance = false;

    _calculatedAmounts.forEach((uid, amount) {
      final member = group.allMembers.firstWhere((m) => m.userId == uid);
      if (member.balance < amount) {
        insufficientBalance = true;
      }
      participants.add(Participant(
        userId: uid,
        userName: member.userName,
        amountDeducted: amount,
        customRatio: _splitMode == 'custom' ? _customRatios[uid] : null,
      ));
    });

    if (insufficientBalance) {
      Helpers.showErrorSnackBar(context, 'One or more participants have insufficient balance.');
      return;
    }

    final transaction = Transaction(
      id: const Uuid().v4(), // Temporary ID, DB will assign real one usually or we use UUID
      groupId: group.id,
      amount: widget.amount,
      paidBy: user.id,
      description: widget.description,
      splitMode: _splitMode,
      participants: participants,
      createdAt: DateTime.now(),
    );

    try {
      await groupProvider.makePayment(transaction);
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            amount: widget.amount,
            participantCount: participants.length,
          ),
        ),
        (route) => route.isFirst, // Go back to main
      );
    } catch (e) {
      Helpers.showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final group = groupProvider.selectedGroup;
    if (group == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(title: const Text('Split Mode')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LinearProgressIndicator(value: 1.0, color: AppColors.primary),
                const SizedBox(height: AppSpacing.md),
                const Text('Step 3/3', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                const Text('How to split?', style: AppTextStyles.headline2),
                const SizedBox(height: AppSpacing.md),
                
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Equal Split'),
                        value: 'equal',
                        groupValue: _splitMode,
                        onChanged: (val) {
                          setState(() {
                            _splitMode = val!;
                            _calculateEqualSplit();
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Custom Ratio'),
                        value: 'custom',
                        groupValue: _splitMode,
                        onChanged: (val) {
                          setState(() {
                            _splitMode = val!;
                            // Initialize ratios
                            for (var uid in widget.selectedUserIds) {
                              _customRatios[uid] = 0;
                            }
                            _isValid = false; // Initially invalid until set
                            _validationError = 'Total must be 100%';
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (_validationError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                _validationError!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
            
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: widget.selectedUserIds.length,
              itemBuilder: (context, index) {
                final userId = widget.selectedUserIds[index];
                final member = group.allMembers.firstWhere((m) => m.userId == userId);
                final amount = _calculatedAmounts[userId] ?? 0;
                final bool hasBalance = member.balance >= amount;

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        CircleAvatar(child: Text(member.userName[0].toUpperCase())),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(member.userName, style: AppTextStyles.body1),
                              Text(
                                'Balance: ${Helpers.formatCurrency(member.balance)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: hasBalance ? AppColors.textSecondary : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_splitMode == 'custom')
                          SizedBox(
                            width: 60,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                suffixText: '%',
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              onChanged: (val) => _onRatioChanged(userId, val),
                            ),
                          ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          Helpers.formatCurrency(amount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: CustomButton(
              text: 'Confirm & Pay',
              onPressed: _isValid ? _processPayment : null,
              isLoading: groupProvider.isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
