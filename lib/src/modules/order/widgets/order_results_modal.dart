import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/modules/order/widgets/order_analytic_result_item.dart';
import 'package:serum_mobile/src/modules/order/widgets/order_patient_header_card.dart';
import 'package:serum_mobile/src/widgets/common/empty_state_view.dart';
import 'package:serum_mobile/src/widgets/common/status_badge.dart';

class OrderResultsModal extends StatelessWidget {
  const OrderResultsModal({
    super.key,
    required this.order,
  });

  final OrderInDb order;

  static void show(BuildContext context, OrderInDb order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OrderResultsModal(order: order),
    );
  }

  String _formatDate(int timestamp) {
    if (timestamp <= 0) return 'Fecha no disponible';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy • hh:mm a').format(date);
  }

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
    final size = MediaQuery.of(context).size;

    final folio = order.id.length >= 8
        ? 'FOL-${order.id.substring(0, 8).toUpperCase()}'
        : 'FOL-${order.id.toUpperCase()}';

    return Container(
      height: size.height * 0.88,
      decoration: const BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: ColorPalette.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          folio,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: ColorPalette.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: order.status),
                        if (order.isBlocked) ...[
                          const SizedBox(width: 6),
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
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(order.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorPalette.outline,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: ColorPalette.outlineVariant),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OrderPatientHeaderCard(order: order),
                  const SizedBox(height: 18),

                  // Estudios Solicitados
                  Text(
                    'Estudios Solicitados (${order.items.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: order.items.map((item) {
                      return Chip(
                        label: Text(item.name),
                        backgroundColor: ColorPalette.surfaceContainerLow,
                        side: const BorderSide(
                          color: ColorPalette.outlineVariant,
                          width: 0.8,
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Parámetros y Resultados Analíticos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Resultados Analíticos (${order.results.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (order.results.isNotEmpty)
                        Text(
                          'Capturados por Laboratorio',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: ColorPalette.outline,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (order.results.isEmpty)
                    const EmptyStateView(
                      icon: Icons.science_outlined,
                      title: 'Pendiente de Procesamiento Analítico',
                      message:
                          'Las muestras aún no cuentan con resultados capturados en el banco de análisis.',
                    )
                  else
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.results.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          color: ColorPalette.outlineVariant,
                        ),
                        itemBuilder: (context, index) {
                          return OrderAnalyticResultItem(
                            result: order.results[index],
                          );
                        },
                      ),
                    ),

                  if (order.discounts.isNotEmpty || order.services.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Resumen Financiero',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorPalette.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ColorPalette.outlineVariant,
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal Bruto:',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: ColorPalette.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                _formatCents(order.grossTotal),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                          if (order.services.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            ...order.services.map((s) => Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Servicio: ${s.name}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    Text(
                                      _formatCents(s.price),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                )),
                          ],
                          if (order.discounts.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            ...order.discounts.map((d) => Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Descuento (${d.description.isNotEmpty ? d.description : (d.isPercentage ? "${d.value}%" : "\$${d.value}")}):',
                                        style: const TextStyle(
                                          color: ColorPalette.error,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '- ${_formatCents(d.appliedAmount)}',
                                      style: const TextStyle(
                                        color: ColorPalette.error,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                          const Divider(height: 12, thickness: 0.5, color: ColorPalette.outlineVariant),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Orden:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                _formatCents(order.totalPrice),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: ColorPalette.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (order.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Observaciones / Notas Clínicas',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorPalette.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ColorPalette.outlineVariant,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        order.notes!,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
