part of 'cash_shift_mobile_cubit.dart';

enum CashShiftMobileStatus {
  initial,
  loading,
  success,
  failure,
}

class CashShiftMobileState {
  final CashShiftMobileStatus status;
  final List<CashShiftInDb> shifts;
  final List<CashShiftInDb> filteredShifts;
  final String filter; // 'all', 'open', 'closed', 'discrepancy'
  final String searchQuery;
  final String? errorMessage;

  const CashShiftMobileState({
    this.status = CashShiftMobileStatus.initial,
    this.shifts = const [],
    this.filteredShifts = const [],
    this.filter = 'all',
    this.searchQuery = '',
    this.errorMessage,
  });

  int get activeShiftsCount => shifts.where((s) => s.isOpen).length;

  int get totalRevenueCents =>
      shifts.fold<int>(0, (sum, s) => sum + s.totalBalance);

  int get discrepancyShiftsCount => shifts
      .where((s) => !s.isOpen && s.difference != null && s.difference != 0)
      .length;

  CashShiftMobileState copyWith({
    CashShiftMobileStatus? status,
    List<CashShiftInDb>? shifts,
    List<CashShiftInDb>? filteredShifts,
    String? filter,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CashShiftMobileState(
      status: status ?? this.status,
      shifts: shifts ?? this.shifts,
      filteredShifts: filteredShifts ?? this.filteredShifts,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
