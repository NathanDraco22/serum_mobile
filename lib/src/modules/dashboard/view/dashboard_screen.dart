import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/modules/dashboard/widgets/pending_approvals_banner.dart';
import 'package:serum_mobile/src/widgets/common/kpi_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionCubit = context.watch<AppSessionCubit>();
    final user = sessionCubit.state.currentUser;
    final branch = sessionCubit.state.currentBranch;

    final blockedOrders = _orders.where((o) => o.isBlocked).toList();
    final activeShifts = _shifts.where((s) => s.closedAt == null).toList();

    // Total de ventas en centavos
    final totalSalesCents = _orders.fold<int>(
      0,
      (sum, order) => sum + order.totalPrice,
    );

    // Total de pruebas solicitadas
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
          IconButton(
            tooltip: 'Cerrar Sesión',
            icon: const Icon(Icons.logout_rounded, color: ColorPalette.outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('¿Cerrar Sesión?'),
                  content: const Text(
                    'Se cerrará tu sesión de supervisor en este dispositivo.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.error,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 40),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        sessionCubit.logout();
                      },
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(showLoading: false),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header de Bienvenida con datos del supervisor
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorPalette.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: ColorPalette.outlineVariant,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: ColorPalette.primary.withAlpha(30),
                            child: Text(
                              (user?.name.isNotEmpty ?? false)
                                  ? user!.name[0].toUpperCase()
                                  : 'S',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Supervisor',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: ColorPalette.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        branch?.name ?? 'Sede Principal',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: ColorPalette.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ColorPalette.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Nivel ${user?.accessLevel ?? 4}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Banner Reactivo de Aprobaciones Pendientes
                    PendingApprovalsBanner(
                      pendingCount: blockedOrders.length,
                      onTap: () => context.go('/approvals'),
                    ),
                    const SizedBox(height: 20),

                    // Título de Métricas
                    Text(
                      'Métricas del Día',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cuadrícula 2x2 de KPIs
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.25,
                      children: [
                        KpiCard(
                          title: 'Ventas Totales',
                          value: _formatCents(totalSalesCents),
                          icon: Icons.payments_rounded,
                          iconColor: ColorPalette.primary,
                          subtitle: '${_orders.length} órdenes emitidas',
                          onTap: () => context.go('/orders'),
                        ),
                        KpiCard(
                          title: 'Órdenes Clínicas',
                          value: '${_orders.length}',
                          icon: Icons.receipt_long_rounded,
                          iconColor: ColorPalette.secondary,
                          subtitle: '$totalTestsCount pruebas solicitadas',
                          onTap: () => context.go('/orders'),
                        ),
                        KpiCard(
                          title: 'Turnos de Caja',
                          value: '${activeShifts.length} abiertas',
                          icon: Icons.point_of_sale_rounded,
                          iconColor: ColorPalette.tertiary,
                          subtitle: 'En todas las sucursales',
                          onTap: () => context.go('/cash-shifts'),
                        ),
                        KpiCard(
                          title: 'Por Autorizar',
                          value: '${blockedOrders.length}',
                          icon: Icons.verified_user_rounded,
                          iconColor: blockedOrders.isNotEmpty
                              ? ColorPalette.warning
                              : ColorPalette.success,
                          subtitle: blockedOrders.isNotEmpty
                              ? 'Descuento retenido'
                              : 'Todo al día',
                          onTap: () => context.go('/approvals'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Accesos Directos
                    Text(
                      'Acciones Rápidas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/orders'),
                            icon: const Icon(Icons.search_rounded, size: 20),
                            label: const Text('Buscar Órdenes'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.go('/cash-shifts'),
                            icon: const Icon(Icons.balance_rounded, size: 20),
                            label: const Text('Ver Arqueos'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
