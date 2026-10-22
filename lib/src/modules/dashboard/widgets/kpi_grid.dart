import 'package:flutter/material.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/widgets/common/kpi_card.dart';

/// Cuadrícula modular con los KPIs principales del día para el supervisor/administrador.
class KpiGrid extends StatelessWidget {
  final String totalSalesFormatted;
  final int ordersCount;
  final int testsCount;
  final int activeShiftsCount;
  final int blockedOrdersCount;
  final VoidCallback onTapSales;
  final VoidCallback onTapOrders;
  final VoidCallback onTapShifts;
  final VoidCallback? onTapApprovals;
  final bool showApprovalsKpi;

  const KpiGrid({
    super.key,
    required this.totalSalesFormatted,
    required this.ordersCount,
    required this.testsCount,
    required this.activeShiftsCount,
    required this.blockedOrdersCount,
    required this.onTapSales,
    required this.onTapOrders,
    required this.onTapShifts,
    this.onTapApprovals,
    this.showApprovalsKpi = true,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        KpiCard(
          title: 'Ventas Totales',
          value: totalSalesFormatted,
          icon: Icons.payments_rounded,
          iconColor: ColorPalette.primary,
          subtitle: '$ordersCount órdenes emitidas',
          onTap: onTapSales,
        ),
        KpiCard(
          title: 'Órdenes Clínicas',
          value: '$ordersCount',
          icon: Icons.receipt_long_rounded,
          iconColor: ColorPalette.secondary,
          subtitle: '$testsCount pruebas solicitadas',
          onTap: onTapOrders,
        ),
        KpiCard(
          title: 'Turnos de Caja',
          value: '$activeShiftsCount abiertas',
          icon: Icons.point_of_sale_rounded,
          iconColor: ColorPalette.tertiary,
          subtitle: 'En todas las sucursales',
          onTap: onTapShifts,
        ),
        if (showApprovalsKpi && onTapApprovals != null)
          KpiCard(
            title: 'Por Autorizar',
            value: '$blockedOrdersCount',
            icon: Icons.verified_user_rounded,
            iconColor: blockedOrdersCount > 0
                ? ColorPalette.warning
                : ColorPalette.success,
            subtitle: blockedOrdersCount > 0
                ? 'Descuento retenido'
                : 'Todo al día',
            onTap: onTapApprovals!,
          ),
      ],
    );
  }
}
