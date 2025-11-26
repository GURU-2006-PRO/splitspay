import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const GroupCard({
    Key? key,
    required this.group,
    required this.currentUserId,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find current user's balance
    double myBalance = 0;
    try {
      final me = group.allMembers.firstWhere((m) => m.userId == currentUserId);
      myBalance = me.balance;
    } catch (e) {
      // User not in group
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                // Header Row
                Row(
                  children: [
                    // Group Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    
                    // Group Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: AppTextStyles.headline3.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.people, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${group.memberCount} members',
                                style: AppTextStyles.caption,
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.family_restroom, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${group.families.length} groups',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Balance Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: myBalance >= 0 
                            ? AppColors.success.withOpacity(0.1) 
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: myBalance >= 0 ? AppColors.success : AppColors.error,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            Helpers.formatCurrency(myBalance),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: myBalance >= 0 ? AppColors.success : AppColors.error,
                            ),
                          ),
                          Text(
                            'Balance',
                            style: TextStyle(
                              fontSize: 10,
                              color: myBalance >= 0 ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.sm),
                
                // Family Chips
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: group.families.map((family) {
                    IconData icon;
                    Color color;
                    
                    switch (family.name) {
                      case 'Family':
                        icon = Icons.family_restroom;
                        color = Colors.blue;
                        break;
                      case 'Couple':
                        icon = Icons.favorite;
                        color = Colors.pink;
                        break;
                      case 'Individual (Adult)':
                        icon = Icons.person;
                        color = Colors.green;
                        break;
                      case 'Children':
                        icon = Icons.child_care;
                        color = Colors.orange;
                        break;
                      default:
                        icon = Icons.group;
                        color = AppColors.primary;
                    }
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(
                            '${family.name} (${family.members.length})',
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: AppSpacing.sm),
                
                // Members Preview
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Members:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: group.allMembers.take(8).map((member) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  member.userName,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              );
                            }).toList(),
                          ),
                          if (group.memberCount > 8)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '+${group.memberCount - 8} more',
                                style: AppTextStyles.caption.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Delete Button
                    if (onDelete != null && group.createdBy == currentUserId)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.error,
                        onPressed: () {
                          _showDeleteConfirmation(context);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text('Are you sure you want to delete "${group.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onDelete != null) {
                onDelete!();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
