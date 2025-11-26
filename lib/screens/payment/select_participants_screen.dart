import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import 'split_screen.dart';

class SelectParticipantsScreen extends StatefulWidget {
  final double amount;
  final String description;

  const SelectParticipantsScreen({
    Key? key,
    required this.amount,
    required this.description,
  }) : super(key: key);

  @override
  State<SelectParticipantsScreen> createState() => _SelectParticipantsScreenState();
}

class _SelectParticipantsScreenState extends State<SelectParticipantsScreen> {
  Set<String> _selectedUserIds = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    // Select all by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final group = Provider.of<GroupProvider>(context, listen: false).selectedGroup;
      if (group != null) {
        setState(() {
          _selectedUserIds = group.allMembers.map((m) => m.userId).toSet();
          _selectAll = true;
        });
      }
    });
  }

  void _toggleSelectAll(bool? value, List<Member> members) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        _selectedUserIds = members.map((m) => m.userId).toSet();
      } else {
        _selectedUserIds.clear();
      }
    });
  }

  void _toggleMember(String userId, List<Member> members) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
      _selectAll = _selectedUserIds.length == members.length;
    });
  }

  void _next() {
    if (_selectedUserIds.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SplitScreen(
          amount: widget.amount,
          description: widget.description,
          selectedUserIds: _selectedUserIds.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final group = groupProvider.selectedGroup;

    if (group == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Select Participants')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LinearProgressIndicator(value: 0.66, color: AppColors.primary),
                const SizedBox(height: AppSpacing.md),
                const Text('Step 2/3', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                const Text('Who is involved?', style: AppTextStyles.headline2),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _toggleSelectAll(!_selectAll, group.allMembers),
                  child: Text(_selectAll ? 'Deselect All' : 'Select All'),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: group.allMembers.length,
              itemBuilder: (context, index) {
                final member = group.allMembers[index];
                final isSelected = _selectedUserIds.contains(member.userId);
                
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => _toggleMember(member.userId, group.allMembers),
                  title: Text(member.userName),
                  subtitle: Text(
                    'Balance: ${Helpers.formatCurrency(member.balance)}',
                    style: TextStyle(
                      color: member.balance < 0 ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                  secondary: CircleAvatar(
                    backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                    child: Text(member.userName[0].toUpperCase()),
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_selectedUserIds.length} selected'),
                    if (_selectedUserIds.isNotEmpty)
                      Text(
                        '~${Helpers.formatCurrency(widget.amount / _selectedUserIds.length)} / person',
                        style: AppTextStyles.caption,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                CustomButton(
                  text: 'Next',
                  onPressed: _selectedUserIds.isNotEmpty ? _next : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
