import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'payment/qr_scanner_screen.dart';
import 'payment/add_items_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _merchantController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (result != null && mounted) {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      
      if (groupProvider.selectedGroup == null) {
        _showGroupSelectionDialog(result);
      } else {
        _proceedToParticipantSelection(result);
      }
    }
  }

  void _showGroupSelectionDialog(Map<String, dynamic> paymentData) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final groups = groupProvider.myGroups;

    if (groups.isEmpty) {
      Helpers.showErrorSnackBar(context, 'No groups available. Create a group first.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: groups.map((group) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(group.name[0].toUpperCase()),
              ),
              title: Text(group.name),
              subtitle: Text('${group.memberCount} members'),
              onTap: () {
                groupProvider.selectGroup(group.id);
                Navigator.pop(context);
                _proceedToParticipantSelection(paymentData);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _proceedToParticipantSelection(Map<String, dynamic> paymentData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddItemsScreen(
          paymentData: paymentData,
        ),
      ),
    );
  }

  void _enterManually(String method) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter $method Payment Details',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _merchantController,
                decoration: const InputDecoration(
                  labelText: 'Merchant/Payee Name',
                  hintText: 'e.g., ABC Restaurant',
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '0',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text);
                    final merchant = _merchantController.text.trim();

                    if (amount == null || amount <= 0) {
                      Helpers.showErrorSnackBar(context, 'Please enter a valid amount');
                      return;
                    }

                    if (merchant.isEmpty) {
                      Helpers.showErrorSnackBar(context, 'Please enter merchant name');
                      return;
                    }

                    // For non-UPI payments, we use a dummy link or handle it differently in confirmation
                    // But to keep flow consistent, we'll pass a dummy link and use the note to identify method
                    String upiLink = 'upi://pay?pa=dummy@upi&am=$amount&pn=$merchant';
                    if (method == 'UPI') {
                       upiLink = 'upi://pay?pa=merchant@paytm&am=$amount&pn=$merchant';
                    }

                    final paymentData = {
                      'upiLink': upiLink,
                      'merchantName': merchant,
                      'merchantUpiId': method == 'UPI' ? 'merchant@paytm' : 'N/A',
                      'amount': amount,
                      'transactionNote': '$method Payment to $merchant',
                      'paymentMethod': method, // Pass method explicitly
                    };

                    Navigator.pop(context);
                    
                    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
                    if (groupProvider.selectedGroup == null) {
                      _showGroupSelectionDialog(paymentData);
                    } else {
                      _proceedToParticipantSelection(paymentData);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final groups = groupProvider.myGroups;

    return Scaffold(
      body: groups.isEmpty
          ? _buildEmptyState()
          : _buildPaymentOptions(),
    );
  }

  Widget _buildPaymentOptions() {
    final groupProvider = Provider.of<GroupProvider>(context);
    final selectedGroup = groupProvider.selectedGroup;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Selection
          const Text('Select Group', style: AppTextStyles.headline3),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: DropdownButton<String>(
                value: selectedGroup?.id,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text('Choose a group'),
                items: groupProvider.myGroups.map((group) {
                  return DropdownMenuItem(
                    value: group.id,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                          child: Text(group.name[0].toUpperCase()),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(group.name),
                              Text(
                                '${group.memberCount} members • Pool: ${Helpers.formatCurrency(group.totalBalance)}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    groupProvider.selectGroup(value);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Payment Options
          const Text('Make Payment', style: AppTextStyles.headline3),
          const SizedBox(height: AppSpacing.sm),

          // Scan QR Code
          _buildPaymentOptionCard(
            icon: Icons.qr_code_scanner,
            title: 'Scan QR Code',
            subtitle: 'Scan merchant\'s UPI QR code',
            color: AppColors.primary,
            onTap: selectedGroup != null ? _scanQRCode : null,
          ),

          const SizedBox(height: AppSpacing.md),

          // Enter Manually (UPI)
          _buildPaymentOptionCard(
            icon: Icons.edit,
            title: 'Enter Manually (UPI)',
            subtitle: 'Enter amount and merchant details',
            color: AppColors.success,
            onTap: selectedGroup != null ? () => _enterManually('UPI') : null,
          ),

          const SizedBox(height: AppSpacing.md),

          // Pay via Card
          _buildPaymentOptionCard(
            icon: Icons.credit_card,
            title: 'Pay via Card',
            subtitle: 'Record credit/debit card payment',
            color: Colors.purple,
            onTap: selectedGroup != null ? () => _enterManually('Card') : null,
          ),

          const SizedBox(height: AppSpacing.md),

          // Cash Payment
          _buildPaymentOptionCard(
            icon: Icons.money,
            title: 'Cash Payment',
            subtitle: 'Record cash payment',
            color: Colors.green[800]!,
            onTap: selectedGroup != null ? () => _enterManually('Cash') : null,
          ),


          if (selectedGroup == null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'Please select a group first to make a payment',
                      style: TextStyle(fontSize: 12, color: Color(0xFFF57C00)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: onTap != null ? Colors.grey : Colors.grey[300], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 80, color: AppColors.textSecondary.withOpacity(0.3)),
            const SizedBox(height: AppSpacing.md),
            const Text('No groups available', style: AppTextStyles.headline3),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Create a group first to make payments',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create-group');
              },
              child: const Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
