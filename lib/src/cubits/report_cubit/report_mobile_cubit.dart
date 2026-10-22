import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/src/cubits/report_cubit/report_mobile_state.dart';

class ReportMobileCubit extends Cubit<ReportMobileState> {
  final ReportsRepository reportsRepository;
  String? _currentBranchId;

  ReportMobileCubit({
    required this.reportsRepository,
    String? initialBranchId,
  })  : _currentBranchId = initialBranchId,
        super(const ReportMobileState()) {
    initDefaultPeriod();
  }

  void updateBranchFilter(String? branchId) {
    _currentBranchId = branchId;
    loadReports();
  }

  void initDefaultPeriod() {
    setFilter(ReportTimeFilter.today);
  }

  void setFilter(
    ReportTimeFilter filter, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final now = DateTime.now();
    late DateTime startDateTime;
    late DateTime endDateTime;

    switch (filter) {
      case ReportTimeFilter.today:
        startDateTime = DateTime(now.year, now.month, now.day, 0, 0, 0);
        endDateTime = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;

      case ReportTimeFilter.thisWeek:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        startDateTime = DateTime(monday.year, monday.month, monday.day, 0, 0, 0);
        final sunday = monday.add(const Duration(days: 6));
        endDateTime = DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59, 999);
        break;

      case ReportTimeFilter.thisMonth:
        startDateTime = DateTime(now.year, now.month, 1, 0, 0, 0);
        endDateTime = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        break;

      case ReportTimeFilter.custom:
        if (customStart != null && customEnd != null) {
          startDateTime = DateTime(
            customStart.year,
            customStart.month,
            customStart.day,
            0,
            0,
            0,
          );
          endDateTime = DateTime(
            customEnd.year,
            customEnd.month,
            customEnd.day,
            23,
            59,
            59,
            999,
          );
        } else {
          startDateTime = DateTime(now.year, now.month, now.day, 0, 0, 0);
          endDateTime = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        }
        break;
    }

    emit(state.copyWith(
      timeFilter: filter,
      startDate: startDateTime.millisecondsSinceEpoch,
      endDate: endDateTime.millisecondsSinceEpoch,
    ));

    loadReports();
  }

  Future<void> loadReports() async {
    emit(state.copyWith(
      status: ReportStatus.loading,
      errorMessage: null,
    ));

    try {
      final results = await Future.wait([
        reportsRepository.getFinancialReport(
          startDate: state.startDate,
          endDate: state.endDate,
          branchId: _currentBranchId,
        ),
        reportsRepository.getLabTestsVolumeReport(
          startDate: state.startDate,
          endDate: state.endDate,
          branchId: _currentBranchId,
          limit: 10,
        ),
        reportsRepository.getShiftsAuditReport(
          startDate: state.startDate,
          endDate: state.endDate,
          branchId: _currentBranchId,
        ),
      ]);

      emit(state.copyWith(
        status: ReportStatus.success,
        financialReport: results[0] as FinancialReportResponse,
        volumeReport: results[1] as LabTestsVolumeReportResponse,
        shiftsReport: results[2] as ShiftsAuditReportResponse,
      ));
    } catch (e, stack) {
      debugPrint('[ReportMobileCubit] Error al cargar reportes: $e\n$stack');
      emit(state.copyWith(
        status: ReportStatus.failure,
        errorMessage: 'Error al consultar reportes: $e',
      ));
    }
  }
}
