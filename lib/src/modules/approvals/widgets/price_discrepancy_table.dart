import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';

class PriceDiscrepancyTable extends StatelessWidget {
  const PriceDiscrepancyTable({
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = order.items;
    final services = order.services;
    final discounts = order.discounts;

    // Cálculos consolidados en centavos
    final totalOriginalCents = items.fold<int>(
      0,
      (sum, item) =>
          sum + (item.originalPrice > 0 ? item.originalPrice : item.salePriceApplied),
    );

    final totalAppliedItemsCents = items.fold<int>(
      0,
      (sum, item) => sum + item.salePriceApplied,
    );

    final totalServicesCents = services.fold<int>(
      0,
      (sum, service) => sum + service.price,
    );

    final itemsDiffCents = totalOriginalCents - totalAppliedItemsCents;
    final grossTotal = totalAppliedItemsCents + totalServicesCents;
    final orderDiscountsCents = order.totalDiscounts;
    final totalConsolidatedDiscounts = itemsDiffCents + orderDiscountsCents;

    final totalFinalCents = order.totalPrice > 0
        ? order.totalPrice
        : ((grossTotal - orderDiscountsCents) > 0
            ? (grossTotal - orderDiscountsCents)
            : 0);

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.outlineVariant, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera de columnas para estudios
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Estudio / Análisis',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Catálogo',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Aplicado',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.8, color: ColorPalette.outlineVariant),

          // Filas por cada ítem
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              thickness: 0.5,
              color: ColorPalette.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final original =
                  item.originalPrice > 0 ? item.originalPrice : item.salePriceApplied;
              final applied = item.salePriceApplied;
              final hasDiscount = applied < original;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _formatCents(original),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          color: hasDiscount ? ColorPalette.outline : ColorPalette.onSurface,
                          decoration: hasDiscount ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _formatCents(applied),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: hasDiscount ? ColorPalette.warning : ColorPalette.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Sección de Servicios Adicionales si existen
          if (services.isNotEmpty) ...[
            const Divider(height: 1, thickness: 0.8, color: ColorPalette.outlineVariant),
            Container(
              color: ColorPalette.surfaceContainerLowest,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Row(
                children: [
                  const Icon(Icons.miscellaneous_services_rounded, size: 14, color: ColorPalette.outline),
                  const SizedBox(width: 6),
                  Text(
                    'Servicios Adicionales (${services.length})',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ...services.map((service) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        _formatCents(service.price),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )),
          ],

          // Sección de Descuentos Aplicados en la Orden
          if (discounts.isNotEmpty) ...[
            const Divider(height: 1, thickness: 0.8, color: ColorPalette.outlineVariant),
            Container(
              color: ColorPalette.warningContainer.withAlpha(50),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Row(
                children: [
                  const Icon(Icons.local_offer_rounded, size: 14, color: ColorPalette.warning),
                  const SizedBox(width: 6),
                  Text(
                    'Descuentos en la Orden (${discounts.length})',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF78350F),
                    ),
                  ),
                ],
              ),
            ),
            ...discounts.map((discount) {
              final badgeLabel = discount.isPercentage
                  ? '${discount.value.toStringAsFixed(discount.value.truncateToDouble() == discount.value ? 0 : 1)}%'
                  : '\$${(discount.value).toStringAsFixed(2)}';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: ColorPalette.warning.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badgeLabel,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF78350F),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              discount.description.isNotEmpty
                                  ? discount.description
                                  : 'Descuento general',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '- ${_formatCents(discount.appliedAmount)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.error,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          const Divider(height: 1, thickness: 0.8, color: ColorPalette.outlineVariant),

          // Fila de Totales y Descuento Consolidado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Column(
              children: [
                if (totalConsolidatedDiscounts > 0 || services.isNotEmpty) ...[
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
                        _formatCents(grossTotal + itemsDiffCents),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Descuentos Concedidos:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ColorPalette.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '- ${_formatCents(totalConsolidatedDiscounts)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ColorPalette.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 12, thickness: 0.5, color: ColorPalette.outlineVariant),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total a Cobrar:',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: ColorPalette.onSurfaceVariant,
                          ),
                        ),
                        if (totalConsolidatedDiscounts > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ColorPalette.warning.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Ahorro: -${_formatCents(totalConsolidatedDiscounts)}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.warning,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      _formatCents(totalFinalCents),
                      style: theme.textTheme.titleMedium?.copyWith(
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
      ),
    );
  }
}
