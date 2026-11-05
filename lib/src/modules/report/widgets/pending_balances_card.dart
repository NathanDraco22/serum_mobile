import 'package:flutter/material.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/tools/formatters/currency_formatter.dart';

class PendingBalancesCard extends StatelessWidget {
  final PendingBalancesReportResponse report;

  const PendingBalancesCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = report.summary;

    // Aplanar todas las órdenes pendientes de todas las ramas si hay detalle
    final List<PendingBalanceItem> allOrders = [];
    for (final branch in report.byBranch) {
      allOrders.addAll(branch.orders);
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ColorPalette.warning.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pending_actions_rounded,
                  size: 16,
                  color: ColorPalette.warning,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cuentas por Cobrar (Saldos)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ColorPalette.warningContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${summary.ordersCount} órdenes',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF78350F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tarjeta de KPI de Saldo Total
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ColorPalette.warning.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorPalette.warning.withAlpha(40)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pendiente por Cobrar',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorPalette.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatCentsToCurrency(summary.totalPendingAmount),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF78350F),
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.receipt_long_rounded,
                  color: ColorPalette.warning,
                  size: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (allOrders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'No hay saldos pendientes registrados',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ColorPalette.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else ...[
            Text(
              'Detalle de Órdenes con Saldo',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorPalette.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...allOrders.take(15).map((order) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorPalette.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ColorPalette.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            order.patientName.isNotEmpty
                                ? order.patientName
                                : 'Paciente sin registrar',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Pendiente: ${formatCentsToCurrency(order.pendingAmount)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ColorPalette.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ${formatCentsToCurrency(order.totalPrice)} • Pagado: ${formatCentsToCurrency(order.paidAmount)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: ColorPalette.onSurfaceVariant,
                          ),
                        ),
                        if (order.daysPending > 0)
                          Text(
                            '${order.daysPending} días',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: ColorPalette.outline,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
