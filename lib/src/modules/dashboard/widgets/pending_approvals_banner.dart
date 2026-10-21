import 'package:flutter/material.dart';
import 'package:serum_mobile/config/app_theme.dart';

class PendingApprovalsBanner extends StatelessWidget {
  const PendingApprovalsBanner({
    super.key,
    required this.pendingCount,
    required this.onTap,
  });

  final int pendingCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPending = pendingCount > 0;

    final bgColor = hasPending
        ? ColorPalette.warningContainer
        : ColorPalette.successContainer;
    final borderColor = hasPending
        ? ColorPalette.warning.withAlpha(80)
        : ColorPalette.success.withAlpha(80);
    final iconColor =
        hasPending ? ColorPalette.warning : ColorPalette.success;
    final titleColor = hasPending
        ? const Color(0xFF78350F) // Ámbar oscuro legible
        : const Color(0xFF14532D); // Verde oscuro legible

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                hasPending
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline_rounded,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasPending
                        ? '$pendingCount orden${pendingCount > 1 ? 'es' : ''} esperando autorización'
                        : 'Sin autorizaciones pendientes',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasPending
                        ? 'Toca para revisar precios modificados en ventanilla'
                        : 'Operación regular en todas las sucursales',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: titleColor.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: titleColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
