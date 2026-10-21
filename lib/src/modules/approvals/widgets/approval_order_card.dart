import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/modules/approvals/widgets/price_discrepancy_table.dart';
import 'package:serum_mobile/src/widgets/dialogs/reason_prompt_dialog.dart';

class ApprovalOrderCard extends StatelessWidget {
  const ApprovalOrderCard({
    super.key,
    required this.order,
    required this.isApproving,
    required this.onApprove,
  });

  final OrderInDb order;
  final bool isApproving;
  final void Function(String? reason) onApprove;

  String _formatDate(int timestamp) {
    if (timestamp <= 0) return 'Fecha no disponible';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patientName = order.patientInfo?.name.isNotEmpty == true
        ? order.patientInfo!.name
        : 'Paciente sin registrar';

    final folio = order.id.length >= 8
        ? 'FOL-${order.id.substring(0, 8).toUpperCase()}'
        : 'FOL-${order.id.toUpperCase()}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera: Folio, Estado y Fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ColorPalette.warning.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_clock_rounded,
                        color: ColorPalette.warning,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      folio,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: ColorPalette.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ColorPalette.warningContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ColorPalette.warning.withAlpha(80),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Retenida',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF78350F),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Nombre del Paciente y Fecha
            Text(
              patientName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: ColorPalette.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(order.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ColorPalette.outline,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tabla comparativa de precios (Catálogo vs Aplicado)
            PriceDiscrepancyTable(items: order.items),
            const SizedBox(height: 16),

            // Botón de Aprobación en 1-Tap
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.success,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isApproving
                  ? null
                  : () async {
                      final reason = await ReasonPromptDialog.show(
                        context,
                        orderFolio: folio,
                      );
                      if (reason != null) {
                        onApprove(reason);
                      }
                    },
              icon: isApproving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_circle_rounded, size: 20),
              label: Text(
                isApproving ? 'Autorizando...' : 'Aprobar Orden',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
