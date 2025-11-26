import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/group_model.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<Family> _families = [];

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.isEmpty || _families.isEmpty) return;

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return;

    try {
      await groupProvider.createGroup(
        _groupNameController.text,
        user.id,
        _families,
      );
      
      if (!mounted) return;
      Navigator.pop(context);
      Helpers.showSuccessSnackBar(context, 'Group created successfully!');
    } catch (e) {
      Helpers.showErrorSnackBar(context, e.toString());
    }
  }

  int _getTotalMembers() {
    int total = 0;
    for (var family in _families) {
      total += family.members.length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Group Name', style: AppTextStyles.headline3),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                hintText: 'e.g., Trip to Goa',
                prefixIcon: Icon(Icons.group_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Members', style: AppTextStyles.headline3),
                Text('${_getTotalMembers()} members', style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            ElevatedButton.icon(
              onPressed: () async {
                final member = await _showAddMemberDialog(context);
                if (member != null) {
                  setState(() {
                    if (_families.isEmpty) {
                      _families.add(Family(
                        id: const Uuid().v4(),
                        name: 'Default',
                        members: [member],
                      ));
                    } else {
                      _families[0] = _families[0].copyWith(
                        members: [..._families[0].members, member],
                      );
                    }
                  });
                }
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Add Member'),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Expanded(
              child: _families.isEmpty || _getTotalMembers() == 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: AppSpacing.md),
                          Text('No members added yet', style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: AppSpacing.sm),
                          const Text('Add members to continue', style: AppTextStyles.caption),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _families.isNotEmpty ? _families[0].members.length : 0,
                      itemBuilder: (context, index) {
                        final member = _families[0].members[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                              child: Text(
                                member.userName[0].toUpperCase(),
                                style: const TextStyle(color: AppColors.primary),
                              ),
                            ),
                            title: Text(member.userName),
                            subtitle: member.phoneNumber != null ? Text(member.phoneNumber!) : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () {
                                setState(() {
                                  final updatedMembers = List<Member>.from(_families[0].members);
                                  updatedMembers.removeAt(index);
                                  _families[0] = _families[0].copyWith(members: updatedMembers);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _groupNameController.text.isNotEmpty && _getTotalMembers() > 0
                ? _createGroup
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Create Group'),
          ),
        ),
      ),
    );
  }
}

Future<Member?> _showAddMemberDialog(BuildContext context) {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  return showDialog<Member>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone (Optional)',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                return;
              }
              final member = Member(
                userId: const Uuid().v4(),
                userName: nameController.text.trim(),
                phoneNumber: phoneController.text.isNotEmpty 
                    ? phoneController.text.trim() 
                    : null,
                contribution: 0,
                balance: 0,
                joinedAt: DateTime.now(),
              );
              Navigator.pop(context, member);
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
