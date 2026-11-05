import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/cubits/approvals_cubit/approvals_cubit.dart';
import 'package:serum_mobile/src/cubits/report_cubit/report_mobile_cubit.dart';
import 'package:serum_mobile/src/modules/report/view/report_screen.dart';

class AdministrationScreen extends StatelessWidget {
  const AdministrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsRepo = RepositoryProvider.of<ReportsRepository>(context);
    final sessionBranchId = context.read<AppSessionCubit>().state.currentBranch?.id;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) => ApprovalsCubit(
            ordersRepository: RepositoryProvider.of<OrdersRepository>(ctx),
            appSessionCubit: ctx.read<AppSessionCubit>(),
          )..loadBlockedOrders(),
        ),
        BlocProvider(
          create: (ctx) => ReportMobileCubit(
            reportsRepository: reportsRepo,
            initialBranchId: sessionBranchId,
          ),
        ),
      ],
      child: const _AdministrationView(),
    );
  }
}

class _AdministrationView extends StatelessWidget {
  const _AdministrationView();

  Future<void> _handleRefresh(BuildContext context) async {
    await Future.wait([
      context.read<ApprovalsCubit>().loadBlockedOrders(showLoading: false),
      context.read<ReportMobileCubit>().loadReports(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionCubit = context.watch<AppSessionCubit>();
    final currentUser = sessionCubit.state.currentUser;

    return Scaffold(
      backgroundColor: ColorPalette.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Administración Central',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              currentUser?.name ?? 'Administrador',
              style: theme.textTheme.bodySmall?.copyWith(
                color: ColorPalette.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _handleRefresh(context),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ColorPalette.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorPalette.primary.withAlpha(50)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, size: 14, color: ColorPalette.primary),
                SizedBox(width: 4),
                Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión y Autorizaciones',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tarjetas ejecutivas en fila (Aprobaciones y Usuarios)
                  Row(
                    children: [
                      // Tarjeta 1: Solicitudes de Aprobación
                      Expanded(
                        child: BlocBuilder<ApprovalsCubit, ApprovalsState>(
                          builder: (context, approvalsState) {
                            final pendingCount = approvalsState.blockedOrders.length;
                            final hasPending = pendingCount > 0;

                            return _AdminActionCard(
                              title: 'Aprobaciones',
                              subtitle: hasPending
                                  ? '$pendingCount pendientes'
                                  : 'Todo al día',
                              badgeText: hasPending ? '$pendingCount' : null,
                              badgeColor: hasPending
                                  ? ColorPalette.warning
                                  : ColorPalette.success,
                              icon: Icons.verified_user_rounded,
                              iconColor: hasPending
                                  ? ColorPalette.warning
                                  : ColorPalette.primary,
                              onTap: () {
                                context.push('/approvals');
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Tarjeta 2: Gestión de Usuarios
                      Expanded(
                        child: _AdminActionCard(
                          title: 'Usuarios',
                          subtitle: 'Directorio y roles',
                          icon: Icons.manage_accounts_rounded,
                          iconColor: ColorPalette.primary,
                          onTap: () {
                            context.push('/users');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: ColorPalette.outlineVariant),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.analytics_rounded,
                    size: 18,
                    color: ColorPalette.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Reportes & Analíticas Multi-Sede',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Visor de Reportes Embebido sin su propio AppBar y sin scroll anidado
            const ReportScreen(showAppBar: false, isScrollable: false),
          ],
        ),
      ),
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final String? badgeText;
  final Color? badgeColor;

  const _AdminActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ColorPalette.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorPalette.outlineVariant, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? ColorPalette.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: ColorPalette.outline,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ColorPalette.onSurfaceVariant,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
