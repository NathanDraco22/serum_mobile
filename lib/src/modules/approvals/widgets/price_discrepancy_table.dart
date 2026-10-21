import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';

class PriceDiscrepancyTable extends StatelessWidget {
  const PriceDiscrepancyTable({
    super.key,
    required this.items,
  });

  final List<OrderItem> items;

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

    // Cálculos consolidados en centavos
    final totalOriginalCents = items.fold<int>(
      0,
      (sum, item) => sum + (item.originalPrice > 0 ? item.originalPrice : item.salePriceApplied),
    );

    final totalAppliedCents = items.fold<int>(
      0,
      (sum, item) => sum + item.salePriceApplied,
    );

    final totalDiffCents = totalOriginalCents - totalAppliedCents;
    final discountPercent = totalOriginalCents > 0
        ? ((totalDiffCents / totalOriginalCents) * 100).round()
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorPalette.outlineVariant, width: 0.8),
      ),
      child: Column(
        children: [
          // Cabecera de columnas
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
              final original = item.originalPrice > 0 ? item.originalPrice : item.salePriceApplied;
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
          const Divider(height: 1, thickness: 0.8, color: ColorPalette.outlineVariant),

          // Fila de Totales y Descuento Consolidado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descuento Concedido:',
                      style: TextStyle(fontSize: 12, color: ColorPalette.onSurfaceVariant),
                    ),
                    if (totalDiffCents > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColorPalette.warning.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${_formatCents(totalDiffCents)} (-$discountPercent%)',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ColorPalette.warning,
                          ),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total a Cobrar:',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: ColorPalette.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      _formatCents(totalAppliedCents),
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
