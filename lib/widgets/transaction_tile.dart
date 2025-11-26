import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    Key? key,
    required this.transaction,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppColors.background,
        child: const Icon(Icons.receipt_long, color: AppColors.textSecondary),
      ),
      title: Text(
        transaction.description,
        style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${Helpers.formatDate(transaction.createdAt)} • ${transaction.participantCount} participants',
        style: AppTextStyles.caption,
      ),
      trailing: Text(
        '-${Helpers.formatCurrency(transaction.amount)}',
        style: const TextStyle(
          color: AppColors.textPrimary, // Or red since it's an expense
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
