part of 'approvals_cubit.dart';

enum ApprovalsStatus {
  initial,
  loading,
  success,
  approving,
  rejecting,
  failure,
}

class ApprovalsState {
  final ApprovalsStatus status;
  final List<OrderInDb> blockedOrders;
  final String? approvingOrderId;
  final String? rejectingOrderId;
  final String? errorMessage;
  final String? successMessage;

  const ApprovalsState({
    this.status = ApprovalsStatus.initial,
    this.blockedOrders = const [],
    this.approvingOrderId,
    this.rejectingOrderId,
    this.errorMessage,
    this.successMessage,
  });

  ApprovalsState copyWith({
    ApprovalsStatus? status,
    List<OrderInDb>? blockedOrders,
    String? approvingOrderId,
    String? rejectingOrderId,
    String? errorMessage,
    String? successMessage,
    bool clearApprovingId = false,
    bool clearRejectingId = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ApprovalsState(
      status: status ?? this.status,
      blockedOrders: blockedOrders ?? this.blockedOrders,
      approvingOrderId:
          clearApprovingId ? null : (approvingOrderId ?? this.approvingOrderId),
      rejectingOrderId:
          clearRejectingId ? null : (rejectingOrderId ?? this.rejectingOrderId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
