import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/modules/order/widgets/order_results_modal.dart';
import 'package:serum_mobile/src/widgets/common/status_badge.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
  });

  final OrderInDb order;

  String _formatCents(int cents) {
    final amount = cents / 100.0;
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(amount);
  }

  String _formatDate(int timestamp) {
    if (timestamp <= 0) return 'Fecha no disponible';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final folio = order.id.length >= 8
        ? 'FOL-${order.id.substring(0, 8).toUpperCase()}'
        : 'FOL-${order.id.toUpperCase()}';

    final patientName = order.patientInfo?.name.isNotEmpty == true
        ? order.patientInfo!.name
        : 'Paciente sin registrar';

    final studiesSummary = order.items.isNotEmpty
        ? order.items.map((e) => e.name).join(', ')
        : 'Sin estudios registrados';

    final isFullyPaid = order.paidAmount >= order.totalPrice;
    final resultsCount = order.results.where((r) => r.resultValue?.isNotEmpty == true).length;
    final totalResults = order.results.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => OrderResultsModal.show(context, order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Folio, Estado y Alerta de Bloqueo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        folio,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: ColorPalette.primary,
                        ),
                      ),
                      if (order.isBlocked) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ColorPalette.warningContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Retenida',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: ColorPalette.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 8),

              // Nombre del Paciente
              Text(
                patientName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: ColorPalette.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ColorPalette.outline,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Resumen de Estudios
              Text(
                studiesSummary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ColorPalette.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: ColorPalette.outlineVariant),
              const SizedBox(height: 10),

              // Fila inferior: Fecha, Resultados y Monto
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Resultados listos indicator
                  Row(
                    children: [
                      Icon(
                        resultsCount > 0
                            ? Icons.science_rounded
                            : Icons.science_outlined,
                        size: 16,
                        color: resultsCount > 0
                            ? ColorPalette.primary
                            : ColorPalette.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        totalResults > 0
                            ? '$resultsCount/$totalResults listos'
                            : 'Sin capturar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: resultsCount > 0
                              ? ColorPalette.primary
                              : ColorPalette.outline,
                        ),
                      ),
                    ],
                  ),

                  // Monto y estado de cobro
                  Row(
                    children: [
                      if (order.discounts.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: ColorPalette.warning.withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_offer_rounded,
                                size: 10,
                                color: Color(0xFF78350F),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '-${_formatCents(order.totalDiscounts)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF78350F),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        _formatCents(order.totalPrice),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isFullyPaid
                              ? ColorPalette.success.withAlpha(20)
                              : ColorPalette.warning.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isFullyPaid ? 'Pagada' : 'Saldo',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isFullyPaid
                                ? ColorPalette.success
                                : ColorPalette.warning,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: ColorPalette.outline,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
