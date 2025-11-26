import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../../providers/group_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/group_model.dart';
import '../../models/transaction_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class SplitConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> paymentData;
  final Map<String, Map<String, dynamic>> splits;
  final double totalUnits;

  const SplitConfirmationScreen({
    Key? key,
    required this.paymentData,
    required this.splits,
    required this.totalUnits,
  }) : super(key: key);

  @override
  State<SplitConfirmationScreen> createState() => _SplitConfirmationScreenState();
}

class _SplitConfirmationScreenState extends State<SplitConfirmationScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.paymentData['amount'] as double;
    final merchantName = widget.paymentData['merchantName'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Split'),
      ),
      body: Column(
        children: [
          // Payment Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.success.withOpacity(0.7)],
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 48),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Split Calculated',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  merchantName,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  Helpers.formatCurrency(totalAmount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${widget.splits.length} participants • ${widget.totalUnits.toStringAsFixed(1)} total units',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Split Breakdown
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const Text(
                  'Split Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                
                ...widget.splits.entries.map((entry) {
                  final data = entry.value;
                  final member = data['member'] as Member;
                  final unit = data['unit'] as double;
                  final amount = data['amount'] as double;
                  final newBalance = member.balance - amount;

                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                            child: Text(member.userName[0].toUpperCase()),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.userName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${unit.toStringAsFixed(1)} unit × ${Helpers.formatCurrency(totalAmount / widget.totalUnits)}',
                                  style: AppTextStyles.caption,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Balance: ${Helpers.formatCurrency(member.balance)}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    const Text(' → ', style: TextStyle(fontSize: 11)),
                                    Text(
                                      Helpers.formatCurrency(newBalance),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: newBalance >= 0 ? AppColors.success : AppColors.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Helpers.formatCurrency(amount),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                              if (newBalance < 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Low Balance',
                                    style: TextStyle(fontSize: 9, color: AppColors.error),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: AppSpacing.lg),

                // Warning for low balances
                if (widget.splits.values.any((data) {
                  final member = data['member'] as Member;
                  final amount = data['amount'] as double;
                  return (member.balance - amount) < 0;
                }))
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: AppColors.warning),
                        const SizedBox(width: AppSpacing.sm),
                        const Expanded(
                          child: Text(
                            'Some members have insufficient balance. They should add money to the pool.',
                            style: TextStyle(fontSize: 12, color: Color(0xFFF57C00)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Action Buttons
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _confirmAndPay,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.payment),
                      label: Text(
                        _isProcessing ? 'Processing...' : 'Confirm & Pay via PhonePe',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Adjust Participants'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndPay() async {
    setState(() => _isProcessing = true);

    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final group = groupProvider.selectedGroup;
      final user = authProvider.currentUser;

      if (group == null || user == null) {
        throw Exception('Group or user not found');
      }

      // 1. Update balances in database
      for (var entry in widget.splits.entries) {
        final userId = entry.key;
        final data = entry.value;
        final member = data['member'] as Member;
        final amount = data['amount'] as double;
        final newBalance = member.balance - amount;

        await groupProvider.updateMemberBalance(group.id, userId, newBalance);
      }

      // 2. Create transaction record
      final transaction = Transaction(
        id: '',
        groupId: group.id,
        amount: widget.paymentData['amount'] as double,
        paidBy: user.id,
        description: widget.paymentData['transactionNote'] ?? 'Payment',
        splitMode: 'custom-units',
        participants: widget.splits.entries.map((entry) {
          final data = entry.value;
          return Participant(
            userId: entry.key,
            userName: (data['member'] as Member).userName,
            amountDeducted: data['amount'] as double,
          );
        }).toList(),
        createdAt: DateTime.now(),
      );

      await groupProvider.createTransaction(transaction);

      // 3. Process Payment
      final paymentMethod = widget.paymentData['paymentMethod'] as String? ?? 'UPI';
      
      if (paymentMethod == 'UPI') {
        final upiLink = widget.paymentData['upiLink'] as String;
        
        if (Platform.isAndroid) {
          // Try to launch PhonePe directly
          final intent = AndroidIntent(
            action: 'android.intent.action.VIEW',
            data: upiLink,
            package: 'com.phonepe.app', // Force PhonePe
          );
          
          try {
            await intent.launch();
          } catch (e) {
            // Fallback to standard chooser if PhonePe not found
            final uri = Uri.parse(upiLink);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              throw Exception('Could not open UPI app');
            }
          }
        } else {
          // iOS or other platforms
          final uri = Uri.parse(upiLink);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('Could not open UPI app');
          }
        }
      } else {
        // For Card/Cash, just simulate a delay
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!mounted) return;

      // 4. Show success and return to home
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      Helpers.showSuccessSnackBar(
        context,
        paymentMethod == 'UPI' 
            ? 'Payment split recorded! Complete payment in PhonePe.'
            : '$paymentMethod payment recorded successfully!',
      );
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
