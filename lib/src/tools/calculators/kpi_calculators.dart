import 'package:serum_business/serum_business.dart';

/// Funciones puras de cálculo y agregación matemática para métricas y KPIs móviles.
class KpiCalculators {
  const KpiCalculators._();

  /// Calcula las ventas totales acumuladas en centavos (`int`) a partir de una lista de órdenes.
  static int calculateTotalSalesCents(Iterable<OrderInDb> orders) {
    return orders.fold<int>(0, (sum, order) => sum + order.totalPrice);
  }

  /// Calcula el total de exámenes y pruebas clínicas solicitadas en una lista de órdenes.
  static int calculateTotalTestsCount(Iterable<OrderInDb> orders) {
    return orders.fold<int>(0, (sum, order) => sum + order.items.length);
  }

  /// Filtra y retorna las órdenes que se encuentran bloqueadas por discrepancia o descuento (`isBlocked == true`).
  static List<OrderInDb> filterBlockedOrders(Iterable<OrderInDb> orders) {
    return orders.where((o) => o.isBlocked).toList();
  }

  /// Cuenta el número de turnos de caja actualmente abiertos.
  static int countActiveShifts(Iterable<CashShiftInDb> shifts) {
    return shifts.where((s) => s.isOpen || s.closedAt == null).length;
  }

  /// Cuenta los turnos cerrados que presentaron discrepancia o descuadre de efectivo.
  static int countDiscrepancyShifts(Iterable<CashShiftInDb> shifts) {
    return shifts.where((s) => !s.isOpen && s.difference != null && s.difference != 0).length;
  }

  /// Calcula el total recaudado acumulado en centavos por todos los turnos provistos.
  static int calculateTotalShiftsRevenueCents(Iterable<CashShiftInDb> shifts) {
    return shifts.fold<int>(0, (sum, shift) => sum + shift.totalBalance);
  }
}
