import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/modules/approvals/widgets/price_discrepancy_table.dart';
import 'package:serum_mobile/src/widgets/dialogs/confirm_action_dialog.dart';
import 'package:serum_mobile/src/widgets/dialogs/reason_prompt_dialog.dart';

class ApprovalOrderCard extends StatelessWidget {
  const ApprovalOrderCard({
    super.key,
    required this.order,
    required this.isApproving,
    this.isRejecting = false,
    required this.onApprove,
    required this.onReject,
  });

  final OrderInDb order;
  final bool isApproving;
  final bool isRejecting;
  final void Function(String? reason) onApprove;
  final VoidCallback onReject;

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

    final isBusy = isApproving || isRejecting;

    // Detectar motivo del bloqueo para el badge informativo
    final hasDiscounts = order.discounts.isNotEmpty;
    final hasModifiedItemPrices = order.items.any(
      (item) => item.originalPrice > 0 && item.salePriceApplied < item.originalPrice,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

            // Badge / Chip del Motivo de Retención
            if (hasDiscounts || hasModifiedItemPrices || order.approval?.reason?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorPalette.warning.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorPalette.warning.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: ColorPalette.warning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.approval?.reason?.isNotEmpty == true
                            ? order.approval!.reason!
                            : (hasDiscounts
                                ? 'Requiere autorización por descuento aplicado en ventanilla'
                                : 'Requiere autorización por precio manual por debajo del catálogo'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF78350F),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Tabla comparativa de precios con soporte para OrderDiscount y Servicios
            PriceDiscrepancyTable(order: order),
            const SizedBox(height: 16),

            // Acciones: Rechazar y Aprobar
            Row(
              children: [
                // Botón Secundario: Rechazar
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorPalette.error,
                      side: const BorderSide(color: ColorPalette.error, width: 1.2),
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isBusy
                        ? null
                        : () async {
                            final confirmed = await ConfirmActionDialog.show(
                              context,
                              title: 'Rechazar Orden',
                              message:
                                  '¿Estás seguro de que deseas rechazar y descartar la orden $folio?\n\nEsta orden retenida se eliminará y la ventanilla deberá registrarla nuevamente si corresponde.',
                              confirmLabel: 'Rechazar',
                              cancelLabel: 'Volver',
                              isDestructive: true,
                              icon: Icons.cancel_outlined,
                            );
                            if (confirmed) {
                              onReject();
                            }
                          },
                    icon: isRejecting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.error),
                            ),
                          )
                        : const Icon(Icons.close_rounded, size: 18),
                    label: Text(
                      isRejecting ? 'Rechazando...' : 'Rechazar',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Botón Primario: Aprobar en 1-Tap
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.success,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isBusy
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
