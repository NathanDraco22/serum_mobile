part of 'order_mobile_cubit.dart';

enum OrderMobileStatus {
  initial,
  loading,
  success,
  failure,
}

class OrderMobileState {
  final OrderMobileStatus status;
  final List<OrderInDb> orders;
  final List<OrderInDb> filteredOrders;
  final String searchQuery;
  final String? statusFilter;
  final String? errorMessage;

  const OrderMobileState({
    this.status = OrderMobileStatus.initial,
    this.orders = const [],
    this.filteredOrders = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.errorMessage,
  });

  OrderMobileState copyWith({
    OrderMobileStatus? status,
    List<OrderInDb>? orders,
    List<OrderInDb>? filteredOrders,
    String? searchQuery,
    String? statusFilter,
    String? errorMessage,
    bool clearStatusFilter = false,
    bool clearError = false,
  }) {
    return OrderMobileState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
