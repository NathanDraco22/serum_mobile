part of 'dashboard_mobile_cubit.dart';

enum DashboardMobileStatus {
  initial,
  loading,
  success,
  failure,
}

class DashboardMobileState {
  final DashboardMobileStatus status;
  final List<OrderInDb> orders;
  final List<CashShiftInDb> shifts;
  final String? errorMessage;

  const DashboardMobileState({
    this.status = DashboardMobileStatus.initial,
    this.orders = const [],
    this.shifts = const [],
    this.errorMessage,
  });

  bool get isLoading => status == DashboardMobileStatus.loading;

  int get totalSalesCents => KpiCalculators.calculateTotalSalesCents(orders);

  int get ordersCount => orders.length;

  int get testsCount => KpiCalculators.calculateTotalTestsCount(orders);

  int get activeShiftsCount => KpiCalculators.countActiveShifts(shifts);

  List<OrderInDb> get blockedOrders => KpiCalculators.filterBlockedOrders(orders);

  int get blockedOrdersCount => blockedOrders.length;

  DashboardMobileState copyWith({
    DashboardMobileStatus? status,
    List<OrderInDb>? orders,
    List<CashShiftInDb>? shifts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardMobileState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      shifts: shifts ?? this.shifts,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
