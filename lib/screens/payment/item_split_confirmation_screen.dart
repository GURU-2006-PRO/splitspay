import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../../models/bill_item_model.dart';
import '../../models/group_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/group_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class ItemSplitConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> paymentData;
  final List<BillItem> items;

  const ItemSplitConfirmationScreen({
    Key? key,
    required this.paymentData,
    required this.items,
  }) : super(key: key);

  @override
  State<ItemSplitConfirmationScreen> createState() => _ItemSplitConfirmationScreenState();
}

class _ItemSplitConfirmationScreenState extends State<ItemSplitConfirmationScreen> {
  bool _isProcessing = false;
  late Map<String, double> _userShares;
  late Map<String, List<String>> _userItems; // userId -> list of item names

  @override
  void initState() {
    super.initState();
    _calculateShares();
  }

  void _calculateShares() {
    _userShares = {};
    _userItems = {};

    for (var item in widget.items) {
      final totalConsumed = item.consumedBy.values.fold(0, (sum, qty) => sum + qty);
      if (totalConsumed == 0) continue;

      final pricePerUnit = item.totalPrice / totalConsumed;

      for (var entry in item.consumedBy.entries) {
        final userId = entry.key;
        final quantity = entry.value;
        final share = pricePerUnit * quantity;

        _userShares[userId] = (_userShares[userId] ?? 0) + share;
        _userItems[userId] = (_userItems[userId] ?? [])..add('${item.name} (×$quantity)');
      }
    }

    // Round to 2 decimal places
    _userShares.updateAll((key, value) => double.parse(value.toStringAsFixed(2)));
  }

  double get _totalAmount {
    return _userShares.values.fold(0.0, (sum, amount) => sum + amount);
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

      // 1. Update balances
      for (var entry in _userShares.entries) {
        final userId = entry.key;
        final amount = entry.value;
        final member = group.allMembers.firstWhere((m) => m.userId == userId);
        final newBalance = member.balance - amount;

        await groupProvider.updateMemberBalance(group.id, userId, newBalance);
      }

      // 2. Create transaction
      final transaction = Transaction(
        id: '',
        groupId: group.id,
        amount: _totalAmount,
        paidBy: user.id,
        description: widget.paymentData['transactionNote'] ?? 'Item-based split payment',
        splitMode: 'item-based',
        participants: _userShares.entries.map((entry) {
          final member = group.allMembers.firstWhere((m) => m.userId == entry.key);
          return Participant(
            userId: entry.key,
            userName: member.userName,
            amountDeducted: entry.value,
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
          final intent = AndroidIntent(
            action: 'android.intent.action.VIEW',
            data: upiLink,
            package: 'com.phonepe.app',
          );
          
          try {
            await intent.launch();
          } catch (e) {
            final uri = Uri.parse(upiLink);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              throw Exception('Could not open UPI app');
            }
          }
        } else {
          final uri = Uri.parse(upiLink);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('Could not open UPI app');
          }
        }
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!mounted) return;

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

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final group = groupProvider.selectedGroup;

    if (group == null) {
      return const Scaffold(
        body: Center(child: Text('No group selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Split'),
      ),
      body: Column(
        children: [
          // Summary Card
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
                  'Item-Based Split Calculated',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.paymentData['merchantName'],
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  Helpers.formatCurrency(_totalAmount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${_userShares.length} participants • ${widget.items.length} items',
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
                
                ..._userShares.entries.map((entry) {
                  final member = group.allMembers.firstWhere((m) => m.userId == entry.key);
                  final amount = entry.value;
                  final items = _userItems[entry.key] ?? [];
                  final newBalance = member.balance - amount;

                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                        child: Text(member.userName[0].toUpperCase()),
                      ),
                      title: Text(
                        member.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
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
                      trailing: Text(
                        Helpers.formatCurrency(amount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Items consumed:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 4),
                              ...items.map((item) => Padding(
                                padding: const EdgeInsets.only(left: 8, top: 2),
                                child: Text('• $item', style: const TextStyle(fontSize: 12)),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // Action Button
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
              child: SizedBox(
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
            ),
          ),
        ],
      ),
    );
  }
}
