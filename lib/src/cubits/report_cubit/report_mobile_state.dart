import 'package:serum_business/serum_business.dart';

enum ReportStatus { initial, loading, success, failure }

enum ReportTimeFilter { today, thisWeek, thisMonth, custom }

class ReportMobileState {
  final ReportStatus status;
  final ReportTimeFilter timeFilter;
  final int startDate;
  final int endDate;
  final FinancialReportResponse? financialReport;
  final LabTestsVolumeReportResponse? volumeReport;
  final ShiftsAuditReportResponse? shiftsReport;
  final String? errorMessage;

  const ReportMobileState({
    this.status = ReportStatus.initial,
    this.timeFilter = ReportTimeFilter.today,
    this.startDate = 0,
    this.endDate = 0,
    this.financialReport,
    this.volumeReport,
    this.shiftsReport,
    this.errorMessage,
  });

  bool get isLoading => status == ReportStatus.loading;
  bool get hasData =>
      financialReport != null || volumeReport != null || shiftsReport != null;

  ReportMobileState copyWith({
    ReportStatus? status,
    ReportTimeFilter? timeFilter,
    int? startDate,
    int? endDate,
    FinancialReportResponse? financialReport,
    LabTestsVolumeReportResponse? volumeReport,
    ShiftsAuditReportResponse? shiftsReport,
    String? errorMessage,
  }) {
    return ReportMobileState(
      status: status ?? this.status,
      timeFilter: timeFilter ?? this.timeFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      financialReport: financialReport ?? this.financialReport,
      volumeReport: volumeReport ?? this.volumeReport,
      shiftsReport: shiftsReport ?? this.shiftsReport,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
