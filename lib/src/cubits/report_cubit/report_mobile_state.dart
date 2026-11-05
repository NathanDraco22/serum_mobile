import 'package:serum_business/serum_business.dart';

enum ReportStatus { initial, loading, success, failure }

enum ReportTimeFilter { today, thisWeek, thisMonth, custom }

enum ReportMobileTab {
  financial,
  topDoctors,
  labTestsVolume,
  pendingBalances,
  shiftsAudit,
}

class ReportMobileState {
  final ReportStatus status;
  final ReportMobileTab activeTab;
  final ReportTimeFilter timeFilter;
  final int startDate;
  final int endDate;
  final String? branchId; // null = Todas las sucursales
  final FinancialReportResponse? financialReport;
  final TopDoctorsReportResponse? topDoctorsReport;
  final LabTestsVolumeReportResponse? volumeReport;
  final PendingBalancesReportResponse? pendingBalancesReport;
  final ShiftsAuditReportResponse? shiftsReport;
  final String? errorMessage;

  const ReportMobileState({
    this.status = ReportStatus.initial,
    this.activeTab = ReportMobileTab.financial,
    this.timeFilter = ReportTimeFilter.today,
    this.startDate = 0,
    this.endDate = 0,
    this.branchId,
    this.financialReport,
    this.topDoctorsReport,
    this.volumeReport,
    this.pendingBalancesReport,
    this.shiftsReport,
    this.errorMessage,
  });

  bool get isLoading => status == ReportStatus.loading;
  bool get hasData =>
      financialReport != null ||
      topDoctorsReport != null ||
      volumeReport != null ||
      pendingBalancesReport != null ||
      shiftsReport != null;

  bool get hasDataForActiveTab {
    switch (activeTab) {
      case ReportMobileTab.financial:
        return financialReport != null;
      case ReportMobileTab.topDoctors:
        return topDoctorsReport != null;
      case ReportMobileTab.labTestsVolume:
        return volumeReport != null;
      case ReportMobileTab.pendingBalances:
        return pendingBalancesReport != null;
      case ReportMobileTab.shiftsAudit:
        return shiftsReport != null;
    }
  }

  ReportMobileState copyWith({
    ReportStatus? status,
    ReportMobileTab? activeTab,
    ReportTimeFilter? timeFilter,
    int? startDate,
    int? endDate,
    String? branchId,
    bool clearBranchId = false,
    FinancialReportResponse? financialReport,
    TopDoctorsReportResponse? topDoctorsReport,
    LabTestsVolumeReportResponse? volumeReport,
    PendingBalancesReportResponse? pendingBalancesReport,
    ShiftsAuditReportResponse? shiftsReport,
    String? errorMessage,
  }) {
    return ReportMobileState(
      status: status ?? this.status,
      activeTab: activeTab ?? this.activeTab,
      timeFilter: timeFilter ?? this.timeFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      branchId: clearBranchId ? null : (branchId ?? this.branchId),
      financialReport: financialReport ?? this.financialReport,
      topDoctorsReport: topDoctorsReport ?? this.topDoctorsReport,
      volumeReport: volumeReport ?? this.volumeReport,
      pendingBalancesReport:
          pendingBalancesReport ?? this.pendingBalancesReport,
      shiftsReport: shiftsReport ?? this.shiftsReport,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
