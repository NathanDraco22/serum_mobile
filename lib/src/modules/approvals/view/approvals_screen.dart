import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/cubits/approvals_cubit/approvals_cubit.dart';
import 'package:serum_mobile/src/modules/approvals/widgets/approval_order_card.dart';
import 'package:serum_mobile/src/widgets/common/empty_state_view.dart';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ApprovalsCubit>(
      create: (ctx) => ApprovalsCubit(
        ordersRepository: ctx.read<OrdersRepository>(),
        appSessionCubit: ctx.read<AppSessionCubit>(),
      )..loadBlockedOrders(),
      child: const _ApprovalsView(),
    );
  }
}

class _ApprovalsView extends StatelessWidget {
  const _ApprovalsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<ApprovalsCubit>();

    return BlocListener<AppSessionCubit, AppSessionState>(
      listenWhen: (prev, curr) =>
          prev.currentBranch?.id != curr.currentBranch?.id,
      listener: (context, sessionState) {
        cubit.loadBlockedOrders();
      },
      child: Scaffold(
        backgroundColor: ColorPalette.surface,
        appBar: AppBar(
          title: const Text('Bandeja de Aprobaciones'),
          actions: [
            IconButton(
              tooltip: 'Actualizar',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => cubit.loadBlockedOrders(),
            ),
          ],
        ),
        body: BlocConsumer<ApprovalsCubit, ApprovalsState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.successMessage!)),
                  ],
                ),
                backgroundColor: ColorPalette.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
                backgroundColor: ColorPalette.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<ApprovalsCubit>();

          if (state.status == ApprovalsStatus.loading && state.blockedOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.blockedOrders.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => cubit.loadBlockedOrders(showLoading: false),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const EmptyStateView(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: ColorPalette.success,
                    title: 'Todo al Día',
                    message:
                        'No hay órdenes retenidas por descuento en este momento.\nCualquier modificación de precio en ventanilla aparecerá aquí en tiempo real.',
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => cubit.loadBlockedOrders(showLoading: false),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              itemCount: state.blockedOrders.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Órdenes Pendientes (${state.blockedOrders.length})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Requiere Aprobación',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: ColorPalette.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final order = state.blockedOrders[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ApprovalOrderCard(
                    order: order,
                    isApproving: state.approvingOrderId == order.id,
                    onApprove: (reason) => cubit.approveOrder(order.id, reason: reason),
                  ),
                );
              },
            ),
          );
        },
      ),
      ),
    );
  }
}
