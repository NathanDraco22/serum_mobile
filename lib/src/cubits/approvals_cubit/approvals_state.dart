part of 'approvals_cubit.dart';

enum ApprovalsStatus {
  initial,
  loading,
  success,
  approving,
  failure,
}

class ApprovalsState {
  final ApprovalsStatus status;
  final List<OrderInDb> blockedOrders;
  final String? approvingOrderId;
  final String? errorMessage;
  final String? successMessage;

  const ApprovalsState({
    this.status = ApprovalsStatus.initial,
    this.blockedOrders = const [],
    this.approvingOrderId,
    this.errorMessage,
    this.successMessage,
  });

  ApprovalsState copyWith({
    ApprovalsStatus? status,
    List<OrderInDb>? blockedOrders,
    String? approvingOrderId,
    String? errorMessage,
    String? successMessage,
    bool clearApprovingId = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ApprovalsState(
      status: status ?? this.status,
      blockedOrders: blockedOrders ?? this.blockedOrders,
      approvingOrderId:
          clearApprovingId ? null : (approvingOrderId ?? this.approvingOrderId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
