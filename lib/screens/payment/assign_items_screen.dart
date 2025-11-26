import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bill_item_model.dart';
import '../../models/group_model.dart';
import '../../providers/group_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'item_split_confirmation_screen.dart';

class AssignItemsScreen extends StatefulWidget {
  final Map<String, dynamic> paymentData;
  final List<BillItem> items;

  const AssignItemsScreen({
    Key? key,
    required this.paymentData,
    required this.items,
  }) : super(key: key);

  @override
  State<AssignItemsScreen> createState() => _AssignItemsScreenState();
}

class _AssignItemsScreenState extends State<AssignItemsScreen> {
  late List<BillItem> _items;
  int _currentItemIndex = 0;

  @override
  void initState() {
    super.initState();
    _items = widget.items.map((item) => item.copyWith()).toList();
  }

  BillItem get _currentItem => _items[_currentItemIndex];

  void _updateItemConsumption(String userId, int quantity) {
    setState(() {
      if (quantity > 0) {
        _currentItem.consumedBy[userId] = quantity;
      } else {
        _currentItem.consumedBy.remove(userId);
      }
    });
  }

  int _getTotalConsumed() {
    return _currentItem.consumedBy.values.fold(0, (sum, qty) => sum + qty);
  }

  void _nextItem() {
    if (_getTotalConsumed() == 0) {
      Helpers.showErrorSnackBar(context, 'Please assign this item to at least one person');
      return;
    }

    if (_getTotalConsumed() != _currentItem.quantity) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quantity Mismatch'),
          content: Text(
            'Total consumed (${_getTotalConsumed()}) doesn\'t match item quantity (${_currentItem.quantity}).\n\nDo you want to continue anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _proceedToNext();
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } else {
      _proceedToNext();
    }
  }

  void _proceedToNext() {
    if (_currentItemIndex < _items.length - 1) {
      setState(() {
        _currentItemIndex++;
      });
    } else {
      _finishAssignment();
    }
  }

  void _previousItem() {
    if (_currentItemIndex > 0) {
      setState(() {
        _currentItemIndex--;
      });
    }
  }

  void _finishAssignment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemSplitConfirmationScreen(
          paymentData: widget.paymentData,
          items: _items,
        ),
      ),
    );
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

    final totalConsumed = _getTotalConsumed();
    final progress = (_currentItemIndex + 1) / _items.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Items (${_currentItemIndex + 1}/${_items.length})'),
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),

          // Current Item Card
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
                  _currentItem.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${Helpers.formatCurrency(_currentItem.price)} × ${_currentItem.quantity} = ${Helpers.formatCurrency(_currentItem.totalPrice)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: totalConsumed == _currentItem.quantity
                        ? AppColors.success
                        : AppColors.warning,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Assigned: $totalConsumed / ${_currentItem.quantity}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
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
                    'Select who consumed this item and how many',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          // Members List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: group.allMembers.length,
              itemBuilder: (context, index) {
                final member = group.allMembers[index];
                final consumed = _currentItem.consumedBy[member.userId] ?? 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  color: consumed > 0 ? AppColors.primaryLight.withOpacity(0.1) : null,
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
                          child: Text(
                            member.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: consumed > 0
                                  ? () => _updateItemConsumption(member.userId, consumed - 1)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppColors.error,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: consumed > 0 ? AppColors.primary : Colors.grey[200],
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Text(
                                consumed.toString(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: consumed > 0 ? Colors.white : Colors.black54,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _updateItemConsumption(member.userId, consumed + 1),
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Navigation Buttons
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
              child: Row(
                children: [
                  if (_currentItemIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousItem,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentItemIndex > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextItem,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _currentItemIndex < _items.length - 1 ? 'Next Item' : 'Calculate Split',
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
}
