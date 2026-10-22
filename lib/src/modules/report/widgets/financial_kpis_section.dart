import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';

class FinancialKpisSection extends StatelessWidget {
  final FinancialSummaryReport summary;

  const FinancialKpisSection({
    super.key,
    required this.summary,
  });

  String _formatCents(int cents) {
    final amount = cents / 100.0;
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen Financiero',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FinancialCard(
                title: 'Total Facturado',
                value: _formatCents(summary.totalBilled),
                subtitle: '${summary.ordersCount} órdenes',
                icon: Icons.receipt_long_rounded,
                color: ColorPalette.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FinancialCard(
                title: 'Total Recaudado',
                value: _formatCents(summary.totalCollected),
                subtitle: '${summary.transactionsCount} pagos',
                icon: Icons.payments_rounded,
                color: ColorPalette.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _PendingReceivablesBanner(
          pendingCents: summary.pendingReceivables,
          formattedAmount: _formatCents(summary.pendingReceivables),
        ),
      ],
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _FinancialCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ColorPalette.outlineVariant,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: ColorPalette.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: ColorPalette.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: ColorPalette.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingReceivablesBanner extends StatelessWidget {
  final int pendingCents;
  final String formattedAmount;

  const _PendingReceivablesBanner({
    required this.pendingCents,
    required this.formattedAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = pendingCents > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isPending
            ? ColorPalette.warning.withAlpha(20)
            : ColorPalette.success.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending
              ? ColorPalette.warning.withAlpha(80)
              : ColorPalette.success.withAlpha(80),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPending
                ? Icons.pending_actions_rounded
                : Icons.check_circle_outline_rounded,
            color: isPending ? ColorPalette.warning : ColorPalette.success,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo Pendiente por Cobrar',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ColorPalette.onSurface,
                  ),
                ),
                Text(
                  formattedAmount,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isPending
                        ? ColorPalette.warning
                        : ColorPalette.success,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isPending ? 'Cobro pendiente' : 'Al día',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isPending ? ColorPalette.warning : ColorPalette.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
