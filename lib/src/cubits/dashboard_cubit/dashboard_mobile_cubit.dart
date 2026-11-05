import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/src/tools/calculators/kpi_calculators.dart';

part 'dashboard_mobile_state.dart';

class DashboardMobileCubit extends Cubit<DashboardMobileState> {
  final OrdersRepository ordersRepository;
  final CashShiftsRepository cashShiftsRepository;

  StreamSubscription? _ordersSub;
  StreamSubscription? _shiftsSub;

  DashboardMobileCubit({
    required this.ordersRepository,
    required this.cashShiftsRepository,
  }) : super(const DashboardMobileState()) {
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    _ordersSub = ordersRepository.eventStream.listen((_) => loadData(showLoading: false));
    _shiftsSub = cashShiftsRepository.eventStream.listen((_) => loadData(showLoading: false));
  }

  @override
  Future<void> close() {
    _ordersSub?.cancel();
    _shiftsSub?.cancel();
    return super.close();
  }

  /// Carga órdenes y turnos de caja en paralelo para el cálculo de KPIs ejecutivos.
  Future<void> loadData({bool showLoading = true}) async {
    if (showLoading) {
      emit(state.copyWith(
        status: DashboardMobileStatus.loading,
        clearError: true,
      ));
    }

    try {
      final results = await Future.wait([
        ordersRepository.getAllOrders(),
        cashShiftsRepository.getAllCashShifts(),
      ]);

      emit(state.copyWith(
        status: DashboardMobileStatus.success,
        orders: results[0] as List<OrderInDb>,
        shifts: results[1] as List<CashShiftInDb>,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardMobileStatus.failure,
        errorMessage: 'Error al actualizar métricas del día: $e',
      ));
    }
  }
}
