import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/group_card.dart';
import 'group_detail_screen.dart';
import 'create_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load groups when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroups();
    });
  }

  void _loadGroups() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      groupProvider.loadMyGroups(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final user = authProvider.currentUser;
    final groups = groupProvider.myGroups;

    return RefreshIndicator(
      onRefresh: () async {
        if (user != null) {
          await groupProvider.loadMyGroups(user.id);
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search groups...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Implement local search filtering if needed
              },
            ),
          ),
          Expanded(
            child: groupProvider.isLoading && groups.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : groups.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return GroupCard(
                            group: group,
                            currentUserId: user?.id ?? '',
                            onTap: () {
                              groupProvider.selectGroup(group.id);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const GroupDetailScreen()),
                              ).then((_) {
                                // Refresh when coming back
                                _loadGroups();
                              });
                            },
                            onDelete: () async {
                              try {
                                await groupProvider.deleteGroup(group.id, user!.id);
                                if (mounted) {
                                  Helpers.showSuccessSnackBar(context, 'Group deleted successfully');
                                }
                              } catch (e) {
                                if (mounted) {
                                  Helpers.showErrorSnackBar(context, e.toString());
                                }
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_outlined, size: 80, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.md),
          const Text('No groups yet', style: AppTextStyles.headline3),
          const SizedBox(height: AppSpacing.xs),
          const Text('Create your first group to start', style: AppTextStyles.body2),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
              ).then((_) {
                // Refresh after creating group
                _loadGroups();
              });
            },
            child: const Text('Create Group'),
          ),
        ],
      ),
    );
  }
}
