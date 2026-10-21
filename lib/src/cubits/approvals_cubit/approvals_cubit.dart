import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';

part 'approvals_state.dart';

class ApprovalsCubit extends Cubit<ApprovalsState> {
  final OrdersRepository ordersRepository;
  final AppSessionCubit appSessionCubit;
  StreamSubscription? _eventsSubscription;

  ApprovalsCubit({
    required this.ordersRepository,
    required this.appSessionCubit,
  }) : super(const ApprovalsState()) {
    _eventsSubscription = ordersRepository.eventStream.listen((_) {
      loadBlockedOrders(showLoading: false);
    });
  }

  @override
  Future<void> close() {
    _eventsSubscription?.cancel();
    return super.close();
  }

  /// Carga y filtra únicamente las órdenes retenidas por descuento
  Future<void> loadBlockedOrders({bool showLoading = true}) async {
    if (showLoading) {
      emit(state.copyWith(
        status: ApprovalsStatus.loading,
        clearError: true,
        clearSuccess: true,
      ));
    }

    try {
      final orders = await ordersRepository.getAllOrders();
      final blocked = orders.where((o) => o.isBlocked).toList();

      // Ordenar por fecha descendente (más recientes primero)
      blocked.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(state.copyWith(
        status: ApprovalsStatus.success,
        blockedOrders: blocked,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ApprovalsStatus.failure,
        errorMessage: 'Error al consultar órdenes bloqueadas: $e',
      ));
    }
  }

  /// Desbloquea y autoriza la orden con los privilegios del supervisor activo
  Future<bool> approveOrder(String orderId, {String? reason}) async {
    final user = appSessionCubit.currentUser;
    if (user == null) {
      emit(state.copyWith(
        status: ApprovalsStatus.failure,
        errorMessage: 'Sesión no disponible para autorizar la orden.',
      ));
      return false;
    }

    emit(state.copyWith(
      status: ApprovalsStatus.approving,
      approvingOrderId: orderId,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final request = OrderApproveRequest(
        approvedBy: UserInfo(id: user.id, name: user.name),
        reason: (reason != null && reason.trim().isNotEmpty)
            ? reason.trim()
            : 'Autorización móvil por supervisor',
      );

      await ordersRepository.approveOrder(orderId, request);

      // Eliminar de la lista local de inmediato para respuesta táctil instantánea
      final updatedList =
          state.blockedOrders.where((order) => order.id != orderId).toList();

      emit(state.copyWith(
        status: ApprovalsStatus.success,
        blockedOrders: updatedList,
        clearApprovingId: true,
        successMessage: 'Orden autorizada correctamente.',
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        status: ApprovalsStatus.failure,
        clearApprovingId: true,
        errorMessage: 'No se pudo autorizar la orden: $e',
      ));
      return false;
    }
  }
}
