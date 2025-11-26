import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class BalanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final String? subtitle;
  final Color? backgroundColor;
  final Color? textColor;

  const BalanceCard({
    Key? key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: backgroundColor == null
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppColors.primary).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              color: textColor ?? Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            Helpers.formatCurrency(amount),
            style: AppTextStyles.headline1.copyWith(
              color: textColor ?? Colors.white,
              fontSize: 32,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTextStyles.caption.copyWith(
                color: textColor ?? Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
