import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';

part 'order_mobile_state.dart';

class OrderMobileCubit extends Cubit<OrderMobileState> {
  final OrdersRepository ordersRepository;
  StreamSubscription? _eventsSubscription;

  OrderMobileCubit({
    required this.ordersRepository,
  }) : super(const OrderMobileState()) {
    _eventsSubscription = ordersRepository.eventStream.listen((_) {
      loadOrders(showLoading: false);
    });
  }

  @override
  Future<void> close() {
    _eventsSubscription?.cancel();
    return super.close();
  }

  /// Carga la lista general de órdenes
  Future<void> loadOrders({bool showLoading = true}) async {
    if (showLoading) {
      emit(state.copyWith(
        status: OrderMobileStatus.loading,
        clearError: true,
      ));
    }

    try {
      final orders = await ordersRepository.getAllOrders();

      final filtered = _filterOrders(
        orders: orders,
        query: state.searchQuery,
        statusFilter: state.statusFilter,
      );

      emit(state.copyWith(
        status: OrderMobileStatus.success,
        orders: orders,
        filteredOrders: filtered,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderMobileStatus.failure,
        errorMessage: 'Error al consultar órdenes: $e',
      ));
    }
  }

  /// Actualiza el término de búsqueda en vivo
  void setSearchQuery(String query) {
    final trimmed = query.trim();
    final filtered = _filterOrders(
      orders: state.orders,
      query: trimmed,
      statusFilter: state.statusFilter,
    );

    emit(state.copyWith(
      searchQuery: trimmed,
      filteredOrders: filtered,
    ));
  }

  /// Aplica filtro por estado operativo o bloqueo
  void setStatusFilter(String? status) {
    final filtered = _filterOrders(
      orders: state.orders,
      query: state.searchQuery,
      statusFilter: status,
    );

    emit(state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
      filteredOrders: filtered,
    ));
  }

  List<OrderInDb> _filterOrders({
    required List<OrderInDb> orders,
    required String query,
    required String? statusFilter,
  }) {
    var result = List<OrderInDb>.from(orders);

    // 1. Filtro por estado
    if (statusFilter != null && statusFilter.isNotEmpty) {
      if (statusFilter == 'blocked') {
        result = result.where((o) => o.isBlocked).toList();
      } else {
        result = result
            .where((o) => o.status.toLowerCase() == statusFilter.toLowerCase())
            .toList();
      }
    }

    // 2. Filtro por texto (Folio o Paciente)
    if (query.isNotEmpty) {
      final lower = query.toLowerCase();
      result = result.where((o) {
        final matchesFolio = o.id.toLowerCase().contains(lower);
        final matchesPatient =
            o.patientInfo?.name.toLowerCase().contains(lower) ?? false;
        final matchesDoctor =
            o.doctorInfo?.name.toLowerCase().contains(lower) ?? false;
        return matchesFolio || matchesPatient || matchesDoctor;
      }).toList();
    }

    // Ordenar descendente por fecha
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }
}
