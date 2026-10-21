import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serum_mobile/config/app_theme.dart';

class DiscrepancyBadge extends StatelessWidget {
  const DiscrepancyBadge({
    super.key,
    required this.difference,
    required this.isOpen,
  });

  final int? difference;
  final bool isOpen;

  String _formatCents(int cents) {
    final absAmount = (cents.abs()) / 100.0;
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(absAmount);
  }

  @override
  Widget build(BuildContext context) {
    if (isOpen) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: ColorPalette.success.withAlpha(20),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ColorPalette.success.withAlpha(60), width: 0.8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_open_rounded, size: 13, color: ColorPalette.success),
            SizedBox(width: 4),
            Text(
              'Turno Activo',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: ColorPalette.success,
              ),
            ),
          ],
        ),
      );
    }

    final diff = difference ?? 0;

    if (diff == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: ColorPalette.successContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ColorPalette.success.withAlpha(60), width: 0.8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF14532D)),
            SizedBox(width: 4),
            Text(
              'Corte Cuadrado',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF14532D),
              ),
            ),
          ],
        ),
      );
    } else if (diff < 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: ColorPalette.errorContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ColorPalette.error.withAlpha(60), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 13, color: ColorPalette.error),
            const SizedBox(width: 4),
            Text(
              'Faltante: -${_formatCents(diff)}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: ColorPalette.error,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: ColorPalette.warningContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ColorPalette.warning.withAlpha(60), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline_rounded, size: 13, color: ColorPalette.warning),
            const SizedBox(width: 4),
            Text(
              'Sobrante: +${_formatCents(diff)}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF78350F),
              ),
            ),
          ],
        ),
      );
    }
  }
}
