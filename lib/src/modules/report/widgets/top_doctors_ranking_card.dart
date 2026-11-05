import 'dart:math';
import 'package:flutter/material.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/tools/formatters/currency_formatter.dart';

class TopDoctorsRankingCard extends StatelessWidget {
  final List<DoctorOrderItem> doctors;

  const TopDoctorsRankingCard({
    super.key,
    required this.doctors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (doctors.isEmpty) {
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
              Icons.medical_services_outlined,
              size: 40,
              color: ColorPalette.onSurfaceVariant.withAlpha(120),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay registros de médicos remitentes en este período',
              style: theme.textTheme.bodySmall?.copyWith(
                color: ColorPalette.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final maxOrders =
        doctors.fold<int>(1, (prev, elem) => max(prev, elem.totalOrders));

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
                  color: ColorPalette.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_search_rounded,
                  size: 16,
                  color: ColorPalette.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Top Médicos Remitentes',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Top ${doctors.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: ColorPalette.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...doctors.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final progress = (item.totalOrders / maxOrders).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: index < 3
                              ? ColorPalette.primary
                              : ColorPalette.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: index < 3
                                ? Colors.white
                                : ColorPalette.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.doctorName.isNotEmpty
                              ? item.doctorName
                              : 'Médico no especificado',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.totalOrders} órdenes',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: ColorPalette.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        index < 3
                            ? ColorPalette.primary
                            : ColorPalette.outline.withAlpha(120),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.specialty.isNotEmpty ? item.specialty : 'General',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: ColorPalette.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'Ingresos: ${formatCentsToCurrency(item.totalRevenue)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: ColorPalette.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
