import 'package:dimpos_store/features/order/models/create_order_response.dart';
import 'package:dimpos_store/features/order/models/order.dart';
import 'package:dimpos_store/features/product/models/customer.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_state.freezed.dart';
part 'order_state.g.dart';

@freezed
class OrderState with _$OrderState {
  const factory OrderState({
    @Default([]) List<Order> allOrders,
    @Default([]) List<Order> filteredOrders,
    @Default(null) Order? selectedOrder,
    @Default(null) Customer? selectedOrderCustomer,
    int? filterStatus,
    DateTime? fromDate,
    DateTime? toDate,
    CreateOrderResponse? createdOrder,
    @Default('') String errorMessage,
    @Default(false) bool isLoading,
    @Default(false) bool isSelectedOrderLoading,
    @Default(1) int currentPage,
    @Default(12) int pageSize,
    @Default(true) bool hasMoreData,
    @Default(false) bool isLoadingMore,
    @Default(false) bool isPaymentSuccess,
  }) = _OrderState;
  factory OrderState.fromJson(Map<String, dynamic> json) =>
      _$OrderStateFromJson(json);
}
