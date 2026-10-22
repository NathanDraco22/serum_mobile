import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/cubits/report_cubit/report_mobile_cubit.dart';
import 'package:serum_mobile/src/cubits/report_cubit/report_mobile_state.dart';
import 'package:serum_mobile/src/modules/report/widgets/date_range_selector.dart';
import 'package:serum_mobile/src/modules/report/widgets/financial_kpis_section.dart';
import 'package:serum_mobile/src/modules/report/widgets/payment_methods_chart.dart';
import 'package:serum_mobile/src/modules/report/widgets/shift_audit_summary_card.dart';
import 'package:serum_mobile/src/modules/report/widgets/top_tests_ranking.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsRepo = context.read<ReportsRepository>();
    final sessionBranchId = context.read<AppSessionCubit>().state.currentBranch?.id;

    return BlocProvider(
      create: (context) => ReportMobileCubit(
        reportsRepository: reportsRepo,
        initialBranchId: sessionBranchId,
      ),
      child: const _ReportView(),
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<ReportMobileCubit>();

    return Scaffold(
      backgroundColor: ColorPalette.surface,
      appBar: AppBar(
        title: Text(
          'Reportes Ejecutivos',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refrescar',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => cubit.loadReports(),
          ),
        ],
      ),
      body: BlocBuilder<ReportMobileCubit, ReportMobileState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => cubit.loadReports(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  const SizedBox(height: 16),

                  if (state.isLoading && !state.hasData) ...[
                    const SizedBox(height: 80),
                    const Center(child: CircularProgressIndicator()),
                  ] else if (state.status == ReportStatus.failure &&
                      !state.hasData) ...[
                    _ErrorStateView(
                      message: state.errorMessage ??
                          'No fue posible obtener los reportes analíticos.',
                      onRetry: () => cubit.loadReports(),
                    ),
                  ] else ...[
                    // 1. Resumen de KPIs Financieros
                    if (state.financialReport != null) ...[
                      FinancialKpisSection(
                        summary: state.financialReport!.summary,
                      ),
                      const SizedBox(height: 16),

                      // 2. Gráfico de Métodos de Pago
                      PaymentMethodsChart(
                        breakdown:
                            state.financialReport!.summary.paymentMethods,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 3. Auditoría de Turnos
                    if (state.shiftsReport != null) ...[
                      ShiftAuditSummaryCard(
                        shiftsReport: state.shiftsReport!,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 4. Pruebas y Packs más Solicitados
                    if (state.volumeReport != null) ...[
                      TopTestsRanking(
                        tests: state.volumeReport!.summary.topTests,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
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
