import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../services/database_service.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_money_screen.dart';
import 'payment/make_payment_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({Key? key}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final DatabaseService _db = DatabaseService();
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final group = Provider.of<GroupProvider>(context, listen: false).selectedGroup;
    if (group == null) return;

    try {
      final transactions = await _db.getTransactionsByGroup(group.id);
      if (mounted) {
        setState(() {
          _transactions = transactions;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final group = groupProvider.selectedGroup;
    final user = authProvider.currentUser;

    if (group == null || user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Find my member details
    final myMember = group.allMembers.firstWhere(
      (m) => m.userId == user.id,
      orElse: () => group.allMembers.first, // Fallback
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await groupProvider.refreshGroup(group.id);
          await _loadTransactions();
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            BalanceCard(
              title: 'My Balance in Group',
              amount: myMember.balance,
              subtitle: 'Total Group Pool: ${Helpers.formatCurrency(group.totalBalance)}',
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddMoneyScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Money'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton(
                    onPressed: myMember.balance > 0 
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MakePaymentScreen()),
                          );
                        }
                      : null,
                    child: const Text('Make Payment'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            const Text('Members', style: AppTextStyles.headline3),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: group.allMembers.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final member = group.allMembers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.background,
                      child: Text(member.userName[0].toUpperCase()),
                    ),
                    title: Text(member.userName),
                    trailing: Text(
                      Helpers.formatCurrency(member.balance),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: member.balance >= 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Transactions', style: AppTextStyles.headline3),
                TextButton(child: const Text('View All'), onPressed: () {}),
              ],
            ),
            
            if (_transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(child: Text('No transactions yet')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  return TransactionTile(transaction: _transactions[index]);
                },
              ),
          ],
        ),
      ),
    );
  }
}
