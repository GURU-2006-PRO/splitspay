import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final double amount;
  final int participantCount;

  const PaymentSuccessScreen({
    Key? key,
    required this.amount,
    required this.participantCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Payment Successful!',
              style: AppTextStyles.headline1,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              Helpers.formatCurrency(amount),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Split between $participantCount people',
              style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            CustomButton(
              text: 'Back to Home',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
