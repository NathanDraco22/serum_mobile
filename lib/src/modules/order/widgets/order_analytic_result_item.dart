import 'package:flutter/material.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/widgets/common/medical_flag_badge.dart';

/// Elemento de fila para desplegar un resultado analítico con rango de referencia y alerta médica.
class OrderAnalyticResultItem extends StatelessWidget {
  final OrderTestResult result;

  const OrderAnalyticResultItem({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = result.resultValue?.isNotEmpty == true;

    String rangeText = '';
    if (result.referenceValues.isNotEmpty) {
      final ref = result.referenceValues.first;
      rangeText = '${ref.minValue} - ${ref.maxValue} ${result.unitOfMeasure}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.parameterName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (rangeText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Ref: $rangeText',
                    style: const TextStyle(
                      fontSize: 11,
                      color: ColorPalette.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hasValue
                    ? '${result.resultValue} ${result.unitOfMeasure}'
                    : 'Pendiente',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: hasValue
                      ? ColorPalette.onSurface
                      : ColorPalette.outline,
                ),
              ),
              const SizedBox(height: 4),
              MedicalFlagBadge(flag: result.alertFlag, compact: true),
            ],
          ),
        ],
      ),
    );
  }
}
