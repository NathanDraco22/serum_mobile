import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';

class TopTestsRanking extends StatelessWidget {
  final List<LabTestVolumeItem> tests;

  const TopTestsRanking({
    super.key,
    required this.tests,
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

    if (tests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ColorPalette.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ColorPalette.outlineVariant,
            width: 0.8,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.biotech_outlined,
              size: 40,
              color: ColorPalette.onSurfaceVariant.withAlpha(120),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay registros de exámenes en este periodo',
              style: theme.textTheme.bodySmall?.copyWith(
                color: ColorPalette.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Máximo de órdenes para normalizar la barra de progreso
    final maxOrders = tests.fold<int>(1, (prev, elem) => max(prev, elem.timesOrdered));

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
                Icons.analytics_rounded,
                color: ColorPalette.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pruebas y Perfiles Más Demandados',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ColorPalette.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tests.length,
            separatorBuilder: (context, index) => const Divider(
              height: 20,
              thickness: 0.6,
              color: ColorPalette.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final item = tests[index];
              final ratio = (item.timesOrdered / maxOrders).clamp(0.05, 1.0);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: index < 3
                              ? ColorPalette.primary.withAlpha(25)
                              : ColorPalette.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: index < 3
                                ? ColorPalette.primary
                                : ColorPalette.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.isPack) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: ColorPalette.tertiary.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PACK',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: ColorPalette.tertiary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      Text(
                        _formatCents(item.totalRevenue),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: ColorPalette.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(width: 30),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 5,
                            backgroundColor:
                                ColorPalette.outlineVariant.withAlpha(60),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              index == 0
                                  ? ColorPalette.primary
                                  : ColorPalette.secondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${item.timesOrdered} ${item.timesOrdered == 1 ? "solicitud" : "solicitudes"}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: ColorPalette.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
