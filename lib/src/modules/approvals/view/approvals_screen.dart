import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/cubits/approvals_cubit/approvals_cubit.dart';
import 'package:serum_mobile/src/modules/approvals/widgets/approval_order_card.dart';

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

    return Scaffold(
      backgroundColor: ColorPalette.surface,
      appBar: AppBar(
        title: const Text('Bandeja de Aprobaciones'),
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
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: ColorPalette.success.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 56,
                            color: ColorPalette.success,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Todo al Día',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No hay órdenes retenidas por descuento en este momento.\nCualquier modificación de precio en ventanilla aparecerá aquí en tiempo real.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ColorPalette.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
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
                            color: ColorPalette.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Descuentos en ventanilla',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: ColorPalette.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final order = state.blockedOrders[index - 1];
                final isApproving = state.approvingOrderId == order.id;

                return ApprovalOrderCard(
                  order: order,
                  isApproving: isApproving,
                  onApprove: (reason) {
                    cubit.approveOrder(order.id, reason: reason);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
