import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/branch_selector_modal.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/kpi_grid.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/pending_approvals_banner.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/quick_actions_section.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/supervisor_header_card.dart';
import 'package:serum_mobile/src/widgets/dialogs/confirm_action_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  List<OrderInDb> _orders = [];
  List<CashShiftInDb> _shifts = [];
  StreamSubscription? _ordersSub;
  StreamSubscription? _shiftsSub;

  @override
  void initState() {
    super.initState();
    _loadData();
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    _shiftsSub?.cancel();
    super.dispose();
  }

  void _subscribeToEvents() {
    final ordersRepo = context.read<OrdersRepository>();
    final shiftsRepo = context.read<CashShiftsRepository>();

    _ordersSub = ordersRepo.eventStream.listen((_) => _loadData(showLoading: false));
    _shiftsSub = shiftsRepo.eventStream.listen((_) => _loadData(showLoading: false));
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final ordersRepo = context.read<OrdersRepository>();
      final shiftsRepo = context.read<CashShiftsRepository>();

      final results = await Future.wait([
        ordersRepo.getAllOrders(),
        shiftsRepo.getAllCashShifts(),
      ]);

      if (mounted) {
        setState(() {
          _orders = results[0] as List<OrderInDb>;
          _shifts = results[1] as List<CashShiftInDb>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatCents(int cents) {
    final amount = cents / 100.0;
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(amount);
  }

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
    final sessionCubit = context.watch<AppSessionCubit>();
    final user = sessionCubit.state.currentUser;
    final branch = sessionCubit.state.currentBranch;
    final hasMultipleBranches = sessionCubit.state.hasMultipleBranches;
    final isAdmin = sessionCubit.state.isAdmin;

    final blockedOrders = _orders.where((o) => o.isBlocked).toList();
    final activeShifts = _shifts.where((s) => s.closedAt == null).toList();

    final totalSalesCents = _orders.fold<int>(
      0,
      (sum, order) => sum + order.totalPrice,
    );

    final totalTestsCount = _orders.fold<int>(
      0,
      (sum, order) => sum + order.items.length,
    );

    return Scaffold(
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
            onPressed: () => _loadData(showLoading: false),
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
      body: BlocListener<AppSessionCubit, AppSessionState>(
        listenWhen: (prev, curr) =>
            prev.currentBranch?.id != curr.currentBranch?.id,
        listener: (context, state) {
          _loadData(showLoading: true);
        },
        child: RefreshIndicator(
          onRefresh: () => _loadData(showLoading: false),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
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
                          pendingCount: blockedOrders.length,
                          onTap: () => context.go('/approvals'),
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
                        totalSalesFormatted: _formatCents(totalSalesCents),
                        ordersCount: _orders.length,
                        testsCount: totalTestsCount,
                        activeShiftsCount: activeShifts.length,
                        blockedOrdersCount: blockedOrders.length,
                        onTapSales: () => context.go('/orders'),
                        onTapOrders: () => context.go('/orders'),
                        onTapShifts: () => context.go('/cash-shifts'),
                        onTapApprovals: isAdmin ? () => context.go('/approvals') : null,
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
        ),
      ),
    );
  }
}
