import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_router.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/cubits/dashboard_cubit/dashboard_mobile_cubit.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/branch_selector_modal.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/kpi_grid.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/pending_approvals_banner.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/quick_actions_section.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/supervisor_header_card.dart';
import 'package:serum_mobile/src/tools/formatters/currency_formatter.dart';
import 'package:serum_mobile/src/widgets/dialogs/confirm_action_dialog.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardMobileCubit>(
      create: (ctx) => DashboardMobileCubit(
        ordersRepository: RepositoryProvider.of<OrdersRepository>(ctx),
        cashShiftsRepository: RepositoryProvider.of<CashShiftsRepository>(ctx),
      )..loadData(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  Future<void> _confirmLogout(BuildContext context) async {
    final sessionCubit = context.read<AppSessionCubit>();
    final confirmed = await ConfirmActionDialog.show(
      context,
      title: '¿Cerrar Sesión?',
      message: 'Se cerrará tu sesión de supervisor en este dispositivo.',
      confirmLabel: 'Cerrar Sesión',
      cancelLabel: 'Cancelar',
      isDestructive: true,
      icon: Icons.logout_rounded,
    );

    if (confirmed) {
      sessionCubit.logout();
    }
  }

  Future<void> _openBranchSelector(BuildContext context) async {
    final sessionCubit = context.read<AppSessionCubit>();
    await sessionCubit.refreshBranches();
    if (!context.mounted) return;

    BranchSelectorModal.show(
      context,
      branches: sessionCubit.state.branches,
      currentBranch: sessionCubit.state.currentBranch,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<DashboardMobileCubit>();
    final sessionCubit = context.watch<AppSessionCubit>();
    final user = sessionCubit.state.currentUser;
    final branch = sessionCubit.state.currentBranch;
    final hasMultipleBranches = sessionCubit.state.hasMultipleBranches;
    final isAdmin = sessionCubit.state.isAdmin;

    return BlocListener<AppSessionCubit, AppSessionState>(
      listenWhen: (prev, curr) =>
          prev.currentBranch?.id != curr.currentBranch?.id,
      listener: (context, state) {
        cubit.loadData(showLoading: true);
      },
      child: Scaffold(
        backgroundColor: ColorPalette.surface,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_hospital_rounded,
                color: ColorPalette.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Serum Mobile',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: ColorPalette.primary,
                ),
              ),
            ],
          ),
          actions: [
            if (hasMultipleBranches)
              IconButton(
                tooltip: 'Cambiar Sucursal',
                icon: const Icon(
                  Icons.swap_horiz_rounded,
                  color: ColorPalette.primary,
                ),
                onPressed: () => _openBranchSelector(context),
              ),
            IconButton(
              tooltip: 'Actualizar',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => cubit.loadData(showLoading: false),
            ),
            IconButton(
              tooltip: 'Reportes Financieros',
              icon: const Icon(Icons.insights_rounded, color: ColorPalette.primary),
              onPressed: () => context.push('/reports'),
            ),
            IconButton(
              tooltip: 'Cerrar Sesión',
              icon: const Icon(Icons.logout_rounded, color: ColorPalette.outline),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
        body: BlocBuilder<DashboardMobileCubit, DashboardMobileState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => cubit.loadData(showLoading: false),
              child: state.isLoading && state.orders.isEmpty && state.shifts.isEmpty
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SupervisorHeaderCard(
                            user: user,
                            branch: branch,
                            onTapBranch: hasMultipleBranches
                                ? () => _openBranchSelector(context)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          if (isAdmin) ...[
                            PendingApprovalsBanner(
                              pendingCount: state.blockedOrdersCount,
                              onTap: () => context.push(AppRouter.approvals),
                            ),
                            const SizedBox(height: 20),
                          ],
                          Text(
                            'Métricas del Día',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          KpiGrid(
                            totalSalesFormatted: formatCentsToCurrency(state.totalSalesCents),
                            ordersCount: state.ordersCount,
                            testsCount: state.testsCount,
                            activeShiftsCount: state.activeShiftsCount,
                            blockedOrdersCount: state.blockedOrdersCount,
                            onTapSales: () => context.go('/orders'),
                            onTapOrders: () => context.go('/orders'),
                            onTapShifts: () => context.go('/cash-shifts'),
                            onTapApprovals:
                                isAdmin ? () => context.push(AppRouter.approvals) : null,
                            showApprovalsKpi: isAdmin,
                          ),
                          const SizedBox(height: 24),
                          QuickActionsSection(
                            onReportsTap: () => context.push('/reports'),
                            onOrdersTap: () => context.go('/orders'),
                            onShiftsTap: () => context.go('/cash-shifts'),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
