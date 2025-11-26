import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/bill_item_model.dart';
import '../../providers/group_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'assign_items_screen.dart';

class AddItemsScreen extends StatefulWidget {
  final Map<String, dynamic> paymentData;

  const AddItemsScreen({
    Key? key,
    required this.paymentData,
  }) : super(key: key);

  @override
  State<AddItemsScreen> createState() => _AddItemsScreenState();
}

class _AddItemsScreenState extends State<AddItemsScreen> {
  final List<BillItem> _items = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _addItem() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text);
    final quantity = int.tryParse(_quantityController.text) ?? 1;

    if (name.isEmpty) {
      Helpers.showErrorSnackBar(context, 'Please enter item name');
      return;
    }

    if (price == null || price <= 0) {
      Helpers.showErrorSnackBar(context, 'Please enter valid price');
      return;
    }

    setState(() {
      _items.add(BillItem(
        id: const Uuid().v4(),
        name: name,
        price: price,
        quantity: quantity,
      ));
    });

    _nameController.clear();
    _priceController.clear();
    _quantityController.text = '1';
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double get _totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void _proceedToAssign() {
    if (_items.isEmpty) {
      Helpers.showErrorSnackBar(context, 'Please add at least one item');
      return;
    }

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    if (groupProvider.selectedGroup == null) {
      Helpers.showErrorSnackBar(context, 'No group selected');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignItemsScreen(
          paymentData: widget.paymentData,
          items: _items,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bill Items'),
      ),
      body: Column(
        children: [
          // Bill Info
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
                  widget.paymentData['merchantName'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Total: ${Helpers.formatCurrency(_totalAmount)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${_items.length} items added',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Add Item Form
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          hintText: 'e.g., Pizza',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          hintText: '0',
                          prefixText: '₹',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Qty',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Text(
                      'No items added yet.\nAdd items from the bill above.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                            child: Text('${index + 1}'),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${Helpers.formatCurrency(item.price)} × ${item.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                Helpers.formatCurrency(item.totalPrice),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.error),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Action
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
                child: ElevatedButton(
                  onPressed: _items.isNotEmpty ? _proceedToAssign : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _items.isEmpty
                        ? 'Add items to continue'
                        : 'Assign Items to People (${_items.length} items)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
