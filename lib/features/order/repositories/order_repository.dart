import 'package:dimpos_store/enums/api_url.dart';
import 'package:dimpos_store/features/common/models/base_response.dart';
import 'package:dimpos_store/features/common/models/paging_response.dart';
import 'package:dimpos_store/features/order/models/create_order_item.dart';
import 'package:dimpos_store/features/order/models/create_order_response.dart';
import 'package:dimpos_store/features/order/models/order.dart';
import 'package:dimpos_store/features/order/models/table_order.dart';
import 'package:dimpos_store/utils/request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_repository.g.dart';

@riverpod
OrderRepository orderRepository(Ref ref) {
  return const OrderRepository();
}

class OrderRepository {
  const OrderRepository();

  // Define methods to interact with the order data source, e.g., fetching orders, updating order status, etc.
  Future<PagingResponse<Order>?> getOrders({
    int page = 1,
    int pageSize = 12,
    int? status,
    int? type,
    String sortBy = 'createdDate',
    bool isAsc = false,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Set default times for date filters
    DateTime adjustedFromDate;
    DateTime adjustedToDate;

    final now = DateTime.now();

    if (fromDate != null) {
      adjustedFromDate =
          DateTime(fromDate.year, fromDate.month, fromDate.day, 0, 0, 0);
    } else {
      adjustedFromDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
    }

    if (toDate != null) {
      adjustedToDate =
          DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
    } else {
      adjustedToDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    }

    final response = await apiClient.getClient(ApiUrl.order).get(
          '/orders',
          queryParameters: convertToQueryParams({
            'page': page,
            'pageSize': pageSize,
            'status': status,
            'type': type,
            'sortBy': sortBy,
            'isAsc': isAsc,
            'fromDate': adjustedFromDate.toIso8601String(),
            'toDate': adjustedToDate.toIso8601String(),
          }),
        );
    final orders = BaseResponse<PagingResponse<Order>?>.fromJson(
      response.data,
      (json) => PagingResponse<Order>.fromJson(
        json as Map<String, dynamic>,
        (item) => Order.fromJson(item as Map<String, dynamic>),
      ),
    ).data;
    return orders;
  }

  Future<void> updateOrderStatus(int orderId, String status) async {}

  Future<Order?> getOrderById(String id) async {
    final response = await apiClient.getClient(ApiUrl.order).get(
          '/orders/$id',
        );
    final order = BaseResponse<Order?>.fromJson(
      response.data,
      (json) => Order.fromJson(json as Map<String, dynamic>),
    ).data;
    return order;
  }

  Future<CreateOrderResponse?> createOrder({
    required String brandId,
    String? customerId,
    String? customerNameSnapshot,
    DateTime? pickupTime,
    String? note,
    int? tableNumberDineIn,
    required int serviceMethod,
    required String storePaymentMethodConfigId,
    List<String>? promotionRuleIds,
    required List<CreateOrderItem> orderItems,
  }) async {
    final response = await apiClient.getClient(ApiUrl.order).post(
      '/orders',
      data: {
        'brandId': brandId,
        'customerId': customerId,
        'customerNameSnapshot': customerNameSnapshot,
        'pickupTime': pickupTime,
        'note': note,
        'type': serviceMethod,
        'tableNumberDineIn': tableNumberDineIn,
        'storePaymentMethodConfigId': storePaymentMethodConfigId,
        'promotionRuleIds': promotionRuleIds,
        'orderItems': orderItems.map((item) => item.toJson()).toList(),
      },
    );
    final order = BaseResponse<CreateOrderResponse?>.fromJson(
      response.data,
      (json) => CreateOrderResponse.fromJson(json as Map<String, dynamic>),
    ).data;
    return order;
  }

  Future<String?> changeOrderPaymentMethod({
    required String orderId,
    required String oldStorePaymentMethodConfigId,
    required String newStorePaymentMethodConfigId,
  }) async {
    final response = await apiClient.getClient(ApiUrl.order).put(
      '/orders/$orderId/payment-method',
      data: {
        'oldStorePaymentMethodConfigId': oldStorePaymentMethodConfigId,
        'newStorePaymentMethodConfigId': newStorePaymentMethodConfigId,
      },
    );
    final paymentUrl = BaseResponse<String?>.fromJson(
      response.data,
      (json) => json as String,
    ).data;
    return paymentUrl;
  }

  Future<void> confirmOrder({
    required String orderId,
    required double amountPaid,
  }) async {
    await apiClient.getClient(ApiUrl.order).put(
      '/orders/$orderId/confirm',
      data: {
        'amountPaid': amountPaid,
      },
    );
  }

  Future<void> cancelOrder({
    required String orderId,
    required String cancellationReason,
  }) async {
    await apiClient.getClient(ApiUrl.order).put(
      '/orders/$orderId/cancel',
      data: {
        'cancellationReason': cancellationReason,
      },
    );
  }

  Future<void> completeOrder(String orderId) async {
    await apiClient.getClient(ApiUrl.order).put(
          '/orders/$orderId/complete',
        );
  }

  Future<List<int>> getExistingTableNumber(String financialShiftId) async {
    final response = await apiClient.getClient(ApiUrl.order).get(
          '/orders/financial-shifts/$financialShiftId/table-numbers',
        );
    final tableNumbers = BaseResponse<TableOrder>.fromJson(
          response.data,
          (json) => TableOrder.fromJson(json as Map<String, dynamic>),
        ).data?.takedTableNumber ??
        [];
    return tableNumbers;
  }
}
