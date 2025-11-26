import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/balance_card.dart';
import 'add_money_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<GroupProvider>(context, listen: false)
            .loadMyGroups(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final user = authProvider.currentUser;
    final groups = groupProvider.myGroups;
    
    // Calculate total pool (sum of all balances in all groups)
    double totalPool = 0;
    double myTotalBalance = 0;
    double totalContributed = 0;
    
    if (user != null) {
      for (var group in groups) {
        // Add to total pool
        totalPool += group.totalBalance;
        
        // Calculate my balance and contribution
        try {
          final member = group.allMembers.firstWhere((m) => m.userId == user.id);
          myTotalBalance += member.balance;
          totalContributed += member.contribution;
        } catch (e) {}
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (user != null) {
          await groupProvider.loadMyGroups(user.id);
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Total Pool Card
          BalanceCard(
            title: 'Total Pool Amount',
            amount: totalPool,
            subtitle: 'Combined balance across ${groups.length} groups',
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'My Balance',
                  myTotalBalance,
                  Icons.account_balance_wallet,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  'My Contribution',
                  totalContributed,
                  Icons.arrow_upward,
                  AppColors.success,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Header with info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Group Pools', style: AppTextStyles.headline3),
              IconButton(
                icon: const Icon(Icons.info_outline, size: 20),
                onPressed: () => _showPoolInfo(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Add money to pool before your trip. All expenses will be deducted from your balance.',
                    style: TextStyle(fontSize: 11, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          if (groupProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (groups.isEmpty)
            _buildEmptyState()
          else
            ...groups.map((group) {
              // Find my balance in this group
              double myBalance = 0;
              double myContribution = 0;
              try {
                final member = group.allMembers.firstWhere((m) => m.userId == user!.id);
                myBalance = member.balance;
                myContribution = member.contribution;
              } catch (e) {}
              
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        AppColors.primaryLight.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group Header
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryLight],
                                ),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Center(
                                child: Text(
                                  group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(group.name, style: AppTextStyles.headline3),
                                  Text('${group.memberCount} members', style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  Helpers.formatCurrency(myBalance),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: myBalance >= 0 ? AppColors.success : AppColors.error,
                                  ),
                                ),
                                Text('My Balance', style: AppTextStyles.caption),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: AppSpacing.md),
                        
                        // Pool Stats
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildPoolStat('Total Pool', group.totalBalance),
                              Container(width: 1, height: 30, color: Colors.grey[300]),
                              _buildPoolStat('My Contribution', myContribution),
                              Container(width: 1, height: 30, color: Colors.grey[300]),
                              _buildPoolStat('My Spent', myContribution - myBalance),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.md),
                        
                        // Member Breakdown
                        ExpansionTile(
                          title: const Text('Member Breakdown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: const EdgeInsets.only(top: AppSpacing.sm),
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Column(
                                children: group.allMembers.map((member) {
                                  final spent = member.contribution - member.balance;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                                          child: Text(
                                            member.userName[0].toUpperCase(),
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(member.userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Added: ${Helpers.formatCurrency(member.contribution)}',
                                                    style: const TextStyle(fontSize: 10, color: AppColors.success),
                                                  ),
                                                  const Text(' • ', style: TextStyle(fontSize: 10)),
                                                  Text(
                                                    'Spent: ${Helpers.formatCurrency(spent)}',
                                                    style: const TextStyle(fontSize: 10, color: AppColors.warning),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          Helpers.formatCurrency(member.balance),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: member.balance >= 0 ? AppColors.success : AppColors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: AppSpacing.md),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  groupProvider.selectGroup(group.id);
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AddMoneyScreen()),
                                  );
                                  // Refresh after returning
                                  if (user != null) {
                                    await groupProvider.loadMyGroups(user.id);
                                  }
                                },
                                icon: const Icon(Icons.add_circle_outline, size: 18),
                                label: const Text('Add to Pool'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  groupProvider.selectGroup(group.id);
                                  Navigator.pushNamed(context, '/group-detail');
                                },
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text('View Details'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, double amount, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(
              Helpers.formatCurrency(amount),
              style: AppTextStyles.headline3.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoolStat(String label, double amount) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          Helpers.formatCurrency(amount),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.md),
          const Text('No groups yet', style: AppTextStyles.headline3),
          const SizedBox(height: AppSpacing.xs),
          const Text('Create a group to start managing shared expenses', style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _showPoolInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('How Pool Works'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1️⃣ Before Trip:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Each member adds money to the shared pool.'),
              SizedBox(height: 12),
              Text('2️⃣ During Trip:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('When making payments, the app automatically splits and deducts from each person\'s balance.'),
              SizedBox(height: 12),
              Text('3️⃣ After Trip:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Check your remaining balance. No manual calculations needed!'),
              SizedBox(height: 12),
              Text('💡 Benefits:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text('• No one owes anyone later\n• Real-time balance updates\n• Transparent expense tracking\n• Smart splitting based on participation'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
