import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import 'select_participants_screen.dart';

class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({Key? key}) : super(key: key);

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  void _next() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectParticipantsScreen(
          amount: amount,
          description: _descriptionController.text.isEmpty 
              ? 'Expense' 
              : _descriptionController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Make Payment')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(value: 0.33, color: AppColors.primary),
            const SizedBox(height: AppSpacing.md),
            const Text('Step 1/3', style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.xs),
            const Text('Enter Amount', style: AppTextStyles.headline2),
            
            const SizedBox(height: 40),
            
            Center(
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixText: '₹',
                  border: InputBorder.none,
                  hintText: '0.00',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            
            const SizedBox(height: 40),
            
            const Text('What is this for?', style: AppTextStyles.body2),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _descriptionController,
              maxLength: 100,
              decoration: const InputDecoration(
                hintText: 'e.g. Dinner at Taj',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            
            const Spacer(),
            
            CustomButton(
              text: 'Next',
              onPressed: Helpers.isValidAmount(_amountController.text) ? _next : null,
            ),
          ],
        ),
      ),
    );
  }
}
