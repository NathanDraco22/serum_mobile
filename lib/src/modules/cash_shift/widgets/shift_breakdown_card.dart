import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/modules/cash_shift/widgets/discrepancy_badge.dart';

class ShiftBreakdownCard extends StatelessWidget {
  const ShiftBreakdownCard({
    super.key,
    required this.shift,
  });

  final CashShiftInDb shift;

  String _formatCents(int cents) {
    final amount = cents / 100.0;
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(amount);
  }

  String _formatDate(int timestamp) {
    if (timestamp <= 0) return 'Fecha no disponible';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOpen = shift.isOpen;

    final branchName = shift.branchName?.isNotEmpty == true
        ? shift.branchName!
        : 'Sede Principal';

    final cashierName = shift.userName?.isNotEmpty == true
        ? shift.userName!
        : 'Cajero en turno';

    final totalCashExpected = shift.initialBalance + shift.cashBalance;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fila Superior: Sucursal y Badge de Estado/Discrepancia
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Icons.store_mall_directory_rounded,
                        color: ColorPalette.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      branchName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: ColorPalette.primary,
                      ),
                    ),
                  ],
                ),
                DiscrepancyBadge(
                  difference: shift.difference,
                  isOpen: isOpen,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Cajero y Tiempos de Operación
            Row(
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  size: 16,
                  color: ColorPalette.outline,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Operador: $cashierName',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: ColorPalette.outline,
                ),
                const SizedBox(width: 6),
                Text(
                  'Apertura: ${_formatDate(shift.openedAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ColorPalette.outline,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (shift.closedAt != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.lock_clock_rounded,
                    size: 14,
                    color: ColorPalette.outline,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Cierre: ${_formatDate(shift.closedAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ColorPalette.outline,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),

            // Cuadrícula de Desglose Multimétodo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorPalette.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorPalette.outlineVariant, width: 0.8),
              ),
              child: Column(
                children: [
                  // Fila 1: Fondo Inicial y Efectivo
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Fondo Inicial',
                          value: _formatCents(shift.initialBalance),
                          icon: Icons.savings_outlined,
                          color: ColorPalette.secondary,
                        ),
                      ),
                      Container(width: 1, height: 36, color: ColorPalette.outlineVariant),
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Efectivo en Caja',
                          value: _formatCents(shift.cashBalance),
                          icon: Icons.payments_outlined,
                          color: ColorPalette.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: ColorPalette.outlineVariant),

                  // Fila 2: Tarjetas y Transferencias
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Tarjeta / TPV',
                          value: _formatCents(shift.cardBalance),
                          icon: Icons.credit_card_rounded,
                          color: ColorPalette.tertiary,
                        ),
                      ),
                      Container(width: 1, height: 36, color: ColorPalette.outlineVariant),
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Transferencia',
                          value: _formatCents(shift.transferBalance),
                          icon: Icons.account_balance_rounded,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Fila de Resumen: Esperado vs Declarado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: ColorPalette.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ColorPalette.outlineVariant, width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Recaudado:',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: ColorPalette.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _formatCents(shift.totalBalance),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: ColorPalette.primary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isOpen ? 'Efectivo Esperado:' : 'Efectivo Declarado:',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: ColorPalette.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _formatCents(isOpen ? totalCashExpected : (shift.declaredCash ?? 0)),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isOpen
                              ? ColorPalette.onSurface
                              : (shift.difference == 0
                                  ? ColorPalette.success
                                  : ColorPalette.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (shift.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Nota: ${shift.notes}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: ColorPalette.outline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: ColorPalette.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
