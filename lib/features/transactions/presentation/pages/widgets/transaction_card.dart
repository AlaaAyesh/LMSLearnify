import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../domain/entities/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Responsive.padding(context, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: transaction.receiptUrl != null
            ? () => _openReceipt(context, transaction.receiptUrl!)
            : null,
        child: Padding(
          padding: Responsive.padding(context, all: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===== Header =====
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      transaction.purchasableName ??
                          transaction.purchasableType,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(context),
                ],
              ),

              SizedBox(height: Responsive.spacing(context, 4)),

              Text(
                DateFormat('yyyy-MM-dd HH:mm')
                    .format(transaction.createdAt),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: Responsive.spacing(context, 12)),
              _divider(),

              /// ===== Info Section =====
              SizedBox(height: Responsive.spacing(context, 12)),
              Row(
                children: [
                  _buildInfoItem(
                    context,
                    Icons.payments_outlined,
                    'المبلغ',
                    '${transaction.amount} ${transaction.currency}',
                  ),
                  _buildInfoItem(
                    context,
                    Icons.account_balance_wallet_outlined,
                    'طريقة الدفع',
                    _getPaymentServiceName(
                      transaction.paymentService,
                    ),
                  ),
                ],
              ),

              if (transaction.transactionId != null) ...[
                SizedBox(height: Responsive.spacing(context, 10)),
                _buildInfoItem(
                  context,
                  Icons.confirmation_number_outlined,
                  'رقم المعاملة',
                  transaction.transactionId!,
                  isFullWidth: true,
                ),
              ],

              if (transaction.receiptUrl != null) ...[
                SizedBox(height: Responsive.spacing(context, 12)),
                _divider(),
                SizedBox(height: Responsive.spacing(context, 10)),
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'عرض الإيصال',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// ===== Status Badge =====
  Widget _buildStatusBadge(BuildContext context) {
    late Color backgroundColor;
    late Color textColor;
    late String statusText;

    if (transaction.isSuccess) {
      backgroundColor = Colors.green.withOpacity(0.12);
      textColor = Colors.green.shade700;
      statusText = 'نجحت';
    } else if (transaction.isPending) {
      backgroundColor = Colors.orange.withOpacity(0.12);
      textColor = Colors.orange.shade700;
      statusText = 'قيد الانتظار';
    } else {
      backgroundColor = Colors.red.withOpacity(0.12);
      textColor = Colors.red.shade700;
      statusText = 'فشلت';
    }

    return Container(
      padding: Responsive.padding(
        context,
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.labelMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// ===== Info Item =====
  Widget _buildInfoItem(
      BuildContext context,
      IconData icon,
      String label,
      String value, {
        bool isFullWidth = false,
      }) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    return isFullWidth ? content : Expanded(child: content);
  }

  Widget _divider() => Container(
    height: 1,
    color: Colors.grey.shade200,
  );

  /// ===== Helpers =====
  String _getPaymentServiceName(String service) {
    switch (service.toLowerCase()) {
      case 'kashier':
        return 'كاشير';
      case 'gplay':
        return 'جوجل بلاي';
      case 'iap':
        return 'شراء داخل التطبيق';
      case 'stripe':
        return 'سترايب';
      case 'wallet':
        return 'محفظة رقمية';
      default:
        return service;
    }
  }

  Future<void> _openReceipt(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showError(context, 'لا يمكن فتح رابط الإيصال');
      }
    } catch (e) {
      _showError(context, 'خطأ في فتح الإيصال');
    }
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}