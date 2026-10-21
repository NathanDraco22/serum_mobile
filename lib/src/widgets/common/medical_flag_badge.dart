import 'package:flutter/material.dart';
import 'package:serum_mobile/config/app_theme.dart';

class MedicalFlagBadge extends StatelessWidget {
  const MedicalFlagBadge({
    super.key,
    required this.flag,
    this.compact = false,
  });

  final String? flag;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final normalized = (flag ?? '').toUpperCase().trim();

    Color bgColor;
    Color textColor;
    IconData? icon;
    String label;

    switch (normalized) {
      case 'NORMAL':
        bgColor = ColorPalette.success.withAlpha(25);
        textColor = ColorPalette.success;
        icon = Icons.check_circle_outline_rounded;
        label = 'Normal';
        break;
      case 'HIGH':
      case 'ALTO':
        bgColor = ColorPalette.error.withAlpha(25);
        textColor = ColorPalette.error;
        icon = Icons.arrow_upward_rounded;
        label = 'Alto';
        break;
      case 'LOW':
      case 'BAJO':
        bgColor = const Color(0xFF0284C7).withAlpha(25);
        textColor = const Color(0xFF0284C7);
        icon = Icons.arrow_downward_rounded;
        label = 'Bajo';
        break;
      case 'ABNORMAL':
      case 'ANORMAL':
      case 'REACTIVO':
      case 'POSITIVO':
        bgColor = const Color(0xFF7C3AED).withAlpha(25);
        textColor = const Color(0xFF7C3AED);
        icon = Icons.warning_amber_rounded;
        label = 'Anormal';
        break;
      default:
        bgColor = ColorPalette.surfaceContainer;
        textColor = ColorPalette.outline;
        icon = null;
        label = 'Normal';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withAlpha(50), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: compact ? 12 : 14),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
