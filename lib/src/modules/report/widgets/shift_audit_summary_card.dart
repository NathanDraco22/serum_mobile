import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';

class ShiftAuditSummaryCard extends StatelessWidget {
  final ShiftsAuditReportResponse shiftsReport;

  const ShiftAuditSummaryCard({
    super.key,
    required this.shiftsReport,
  });

  String _formatCents(int cents) {
    final amount = cents.abs() / 100.0;
    final formatted = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(amount);
    if (cents < 0) return '-$formatted';
    if (cents > 0) return '+$formatted';
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = shiftsReport.summary;
    final hasDiscrepancy = summary.totalDiscrepancies > 0;
    final diff = summary.netDifference;

    Color badgeColor;
    String auditMessage;
    IconData auditIcon;

    if (diff == 0 && !hasDiscrepancy) {
      badgeColor = ColorPalette.success;
      auditMessage = 'Arqueos Cuadrados';
      auditIcon = Icons.check_circle_rounded;
    } else if (diff < 0) {
      badgeColor = ColorPalette.error;
      auditMessage = 'Faltante Neto';
      auditIcon = Icons.warning_rounded;
    } else {
      badgeColor = ColorPalette.warning;
      auditMessage = 'Sobrante Neto';
      auditIcon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
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
              const Icon(
                Icons.account_balance_rounded,
                color: ColorPalette.tertiary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Auditoría Contable de Turnos',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ColorPalette.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(auditIcon, size: 14, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(
                      auditMessage,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _AuditMetricTile(
                  label: 'Turnos Auditados',
                  value: '${summary.totalShifts}',
                  icon: Icons.history_rounded,
                  color: ColorPalette.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AuditMetricTile(
                  label: 'Con Descuadre',
                  value: '${summary.totalDiscrepancies}',
                  icon: Icons.error_outline_rounded,
                  color: hasDiscrepancy ? ColorPalette.error : ColorPalette.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AuditMetricTile(
                  label: 'Diferencia Neta',
                  value: _formatCents(diff),
                  icon: Icons.difference_rounded,
                  color: badgeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuditMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AuditMetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ColorPalette.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
