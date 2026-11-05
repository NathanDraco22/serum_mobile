import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_router.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/cubits/report_cubit/report_mobile_cubit.dart';
import 'package:serum_mobile/src/cubits/report_cubit/report_mobile_state.dart';
import 'package:serum_mobile/src/modules/report/widgets/date_range_selector.dart';
import 'package:serum_mobile/src/modules/report/widgets/financial_kpis_section.dart';
import 'package:serum_mobile/src/modules/report/widgets/payment_methods_chart.dart';
import 'package:serum_mobile/src/modules/report/widgets/pending_balances_card.dart';
import 'package:serum_mobile/src/modules/report/widgets/report_branch_filter_modal.dart';
import 'package:serum_mobile/src/modules/report/widgets/shift_audit_summary_card.dart';
import 'package:serum_mobile/src/modules/report/widgets/top_doctors_ranking_card.dart';
import 'package:serum_mobile/src/modules/report/widgets/top_tests_ranking.dart';

class ReportScreen extends StatelessWidget {
  final bool showAppBar;
  final bool isScrollable;
  final ReportMobileCubit? cubit;

  const ReportScreen({
    super.key,
    this.showAppBar = true,
    this.isScrollable = true,
    this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(
        value: cubit!,
        child: _ReportView(showAppBar: showAppBar, isScrollable: isScrollable),
      );
    }

    try {
      context.read<ReportMobileCubit>();
      return _ReportView(showAppBar: showAppBar, isScrollable: isScrollable);
    } catch (_) {
      final reportsRepo = RepositoryProvider.of<ReportsRepository>(context);
      final sessionBranchId = context.read<AppSessionCubit>().state.currentBranch?.id;

      return BlocProvider(
        create: (context) => ReportMobileCubit(
          reportsRepository: reportsRepo,
          initialBranchId: sessionBranchId,
        ),
        child: _ReportView(showAppBar: showAppBar, isScrollable: isScrollable),
      );
    }
  }
}

class _ReportView extends StatelessWidget {
  final bool showAppBar;
  final bool isScrollable;

  const _ReportView({
    this.showAppBar = true,
    this.isScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<ReportMobileCubit>();
    final sessionCubit = context.watch<AppSessionCubit>();
    final sessionState = sessionCubit.state;
    final branches = sessionState.branches;

    final selectedBranchId = context.select<ReportMobileCubit, String?>(
      (c) => c.state.branchId,
    );

    final selectedBranch = branches.cast<BranchInDb?>().firstWhere(
          (b) => b?.id == selectedBranchId,
          orElse: () => null,
        );

    final branchTitle = selectedBranchId == null
        ? 'Todas las Sucursales'
        : (selectedBranch?.name ?? 'Sucursal');

    final content = BlocBuilder<ReportMobileCubit, ReportMobileState>(
      builder: (context, state) {
        final bodyColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selector de Sede Compacto (si no hay AppBar o si se desea cambiar)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ColorPalette.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorPalette.outlineVariant,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          selectedBranchId == null
                              ? Icons.corporate_fare_rounded
                              : Icons.store_rounded,
                          size: 18,
                          color: ColorPalette.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            branchTitle,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      ReportBranchFilterModal.show(
                        context,
                        branches: branches,
                        currentBranchId: selectedBranchId,
                        onSelected: (newBranchId) {
                          cubit.updateBranchFilter(newBranchId);
                        },
                      );
                    },
                    icon: const Icon(Icons.tune_rounded, size: 14),
                    label: const Text('Cambiar', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

            // Selector de Periodo Temporal
            DateRangeSelector(
              activeFilter: state.timeFilter,
              startDate: state.startDate,
              endDate: state.endDate,
              onFilterSelected: (filter) => cubit.setFilter(filter),
              onCustomRangeSelected: (start, end) => cubit.setFilter(
                ReportTimeFilter.custom,
                customStart: start,
                customEnd: end,
              ),
            ),
            const SizedBox(height: 14),

            // Pestañas de Reportes (Segmented tabs horizontales)
            _buildReportTabs(context, state.activeTab, (tab) => cubit.changeTab(tab)),
            const SizedBox(height: 16),

            if (state.isLoading && !state.hasData) ...[
              const SizedBox(height: 80),
              const Center(child: CircularProgressIndicator()),
            ] else if (state.status == ReportStatus.failure && !state.hasData) ...[
              _ErrorStateView(
                message: state.errorMessage ??
                    'No fue posible obtener los reportes analíticos.',
                onRetry: () => cubit.loadReports(),
              ),
            ] else ...[
              _buildActiveReportView(state),
              const SizedBox(height: 24),
            ],
          ],
        );

        if (!isScrollable) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: bodyColumn,
          );
        }

        return RefreshIndicator(
          onRefresh: () => cubit.loadReports(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: bodyColumn,
          ),
        );
      },
    );

    if (!showAppBar) {
      return content;
    }

    return Scaffold(
      backgroundColor: ColorPalette.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Regresar',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.dashboard);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reportes Ejecutivos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              branchTitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ColorPalette.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cambiar Sede',
            icon: const Icon(
              Icons.tune_rounded,
              color: ColorPalette.primary,
            ),
            onPressed: () {
              ReportBranchFilterModal.show(
                context,
                branches: branches,
                currentBranchId: selectedBranchId,
                onSelected: (newBranchId) {
                  cubit.updateBranchFilter(newBranchId);
                },
              );
            },
          ),
          IconButton(
            tooltip: 'Refrescar',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => cubit.loadReports(),
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildReportTabs(
    BuildContext context,
    ReportMobileTab activeTab,
    ValueChanged<ReportMobileTab> onTabChanged,
  ) {
    final tabs = [
      (ReportMobileTab.financial, 'Finanzas', Icons.monetization_on_outlined),
      (ReportMobileTab.topDoctors, 'Top Médicos', Icons.person_search_outlined),
      (ReportMobileTab.labTestsVolume, 'Exámenes', Icons.science_outlined),
      (ReportMobileTab.pendingBalances, 'Saldos', Icons.pending_actions_outlined),
      (ReportMobileTab.shiftsAudit, 'Turnos Caja', Icons.security_outlined),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((item) {
          final isSelected = activeTab == item.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              avatar: Icon(
                item.$3,
                size: 16,
                color: isSelected ? Colors.white : ColorPalette.onSurfaceVariant,
              ),
              label: Text(item.$2),
              selected: isSelected,
              onSelected: (_) => onTabChanged(item.$1),
              selectedColor: ColorPalette.primary,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : ColorPalette.onSurface,
              ),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected
                      ? ColorPalette.primary
                      : ColorPalette.outlineVariant,
                  width: 0.8,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveReportView(ReportMobileState state) {
    switch (state.activeTab) {
      case ReportMobileTab.financial:
        if (state.financialReport == null) {
          return const Center(child: Text('Sin datos financieros'));
        }
        return Column(
          children: [
            FinancialKpisSection(summary: state.financialReport!.summary),
            const SizedBox(height: 16),
            PaymentMethodsChart(
              breakdown: state.financialReport!.summary.paymentMethods,
            ),
          ],
        );

      case ReportMobileTab.topDoctors:
        if (state.topDoctorsReport == null) {
          return const Center(child: Text('Sin datos de médicos'));
        }
        return TopDoctorsRankingCard(
          doctors: state.topDoctorsReport!.summary.topDoctors,
        );

      case ReportMobileTab.labTestsVolume:
        if (state.volumeReport == null) {
          return const Center(child: Text('Sin datos de exámenes'));
        }
        return TopTestsRanking(
          tests: state.volumeReport!.summary.topTests,
        );

      case ReportMobileTab.pendingBalances:
        if (state.pendingBalancesReport == null) {
          return const Center(child: Text('Sin saldos pendientes'));
        }
        return PendingBalancesCard(
          report: state.pendingBalancesReport!,
        );

      case ReportMobileTab.shiftsAudit:
        if (state.shiftsReport == null) {
          return const Center(child: Text('Sin datos de auditoría de turnos'));
        }
        return ShiftAuditSummaryCard(
          shiftsReport: state.shiftsReport!,
        );
    }
  }
}

class _ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorStateView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.outlineVariant),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: ColorPalette.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Error al cargar reportes',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ColorPalette.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
