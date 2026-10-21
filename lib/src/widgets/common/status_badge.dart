import 'package:flutter/material.dart';
import 'package:serum_mobile/config/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase().trim();

    Color bgColor;
    Color textColor;
    String label;

    switch (normalized) {
      case 'completed':
      case 'completado':
      case 'completada':
        bgColor = ColorPalette.successContainer;
        textColor = const Color(0xFF14532D);
        label = 'Completada';
        break;
      case 'in_process':
      case 'processing':
      case 'en_proceso':
        bgColor = const Color(0xFFE0F2FE);
        textColor = const Color(0xFF0369A1);
        label = 'En Proceso';
        break;
      case 'pending':
      case 'pendiente':
        bgColor = ColorPalette.warningContainer;
        textColor = const Color(0xFF78350F);
        label = 'Pendiente';
        break;
      case 'delivered':
      case 'entregado':
      case 'entregada':
        bgColor = ColorPalette.secondaryContainer;
        textColor = ColorPalette.onSecondaryContainer;
        label = 'Entregada';
        break;
      case 'cancelled':
      case 'cancelado':
      case 'cancelada':
        bgColor = ColorPalette.errorContainer;
        textColor = ColorPalette.onErrorContainer;
        label = 'Cancelada';
        break;
      default:
        bgColor = ColorPalette.surfaceContainer;
        textColor = ColorPalette.onSurfaceVariant;
        label = status;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withAlpha(60), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
