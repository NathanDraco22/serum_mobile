import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';

part 'cash_shift_mobile_state.dart';

class CashShiftMobileCubit extends Cubit<CashShiftMobileState> {
  final CashShiftsRepository cashShiftsRepository;
  StreamSubscription? _eventsSubscription;

  CashShiftMobileCubit({
    required this.cashShiftsRepository,
  }) : super(const CashShiftMobileState()) {
    _eventsSubscription = cashShiftsRepository.eventStream.listen((_) {
      loadShifts(showLoading: false);
    });
  }

  @override
  Future<void> close() {
    _eventsSubscription?.cancel();
    return super.close();
  }

  /// Consulta la lista de turnos y aplica los filtros activos
  Future<void> loadShifts({bool showLoading = true}) async {
    if (showLoading) {
      emit(state.copyWith(
        status: CashShiftMobileStatus.loading,
        clearError: true,
      ));
    }

    try {
      final shifts = await cashShiftsRepository.getAllCashShifts();

      final filtered = _filterShifts(
        shifts: shifts,
        filter: state.filter,
        query: state.searchQuery,
      );

      emit(state.copyWith(
        status: CashShiftMobileStatus.success,
        shifts: shifts,
        filteredShifts: filtered,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CashShiftMobileStatus.failure,
        errorMessage: 'Error al consultar turnos de caja: $e',
      ));
    }
  }

  /// Establece el filtro de auditoría ('all', 'open', 'closed', 'discrepancy')
  void setFilter(String filter) {
    final filtered = _filterShifts(
      shifts: state.shifts,
      filter: filter,
      query: state.searchQuery,
    );

    emit(state.copyWith(
      filter: filter,
      filteredShifts: filtered,
    ));
  }

  /// Actualiza el término de búsqueda por sucursal o cajero
  void setSearchQuery(String query) {
    final trimmed = query.trim();
    final filtered = _filterShifts(
      shifts: state.shifts,
      filter: state.filter,
      query: trimmed,
    );

    emit(state.copyWith(
      searchQuery: trimmed,
      filteredShifts: filtered,
    ));
  }

  List<CashShiftInDb> _filterShifts({
    required List<CashShiftInDb> shifts,
    required String filter,
    required String query,
  }) {
    var result = List<CashShiftInDb>.from(shifts);

    // 1. Filtro por estado / auditoría
    switch (filter) {
      case 'open':
        result = result.where((s) => s.isOpen).toList();
        break;
      case 'closed':
        result = result.where((s) => !s.isOpen).toList();
        break;
      case 'discrepancy':
        result = result
            .where((s) => !s.isOpen && s.difference != null && s.difference != 0)
            .toList();
        break;
      default:
        // 'all': no filtra por estado
        break;
    }

    // 2. Filtro de búsqueda textual
    if (query.isNotEmpty) {
      final lower = query.toLowerCase();
      result = result.where((s) {
        final matchesBranch = s.branchName?.toLowerCase().contains(lower) ?? false;
        final matchesUser = s.userName?.toLowerCase().contains(lower) ?? false;
        final matchesId = s.id.toLowerCase().contains(lower);
        return matchesBranch || matchesUser || matchesId;
      }).toList();
    }

    // Ordenar descendente por fecha de apertura
    result.sort((a, b) => b.openedAt.compareTo(a.openedAt));
    return result;
  }
}
