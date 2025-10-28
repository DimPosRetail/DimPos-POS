import 'package:dimpos_store/enums/order_status.dart';
import 'package:dimpos_store/extensions/iterable_extension.dart';
import 'package:dimpos_store/features/order/models/create_order_item.dart';
import 'package:dimpos_store/features/order/models/extra_order_item.dart';
import 'package:dimpos_store/features/order/models/order.dart';
import 'package:dimpos_store/features/order/models/order_selected_option.dart';
import 'package:dimpos_store/features/order/repositories/inventory_repository.dart';
import 'package:dimpos_store/features/order/repositories/order_repository.dart';
import 'package:dimpos_store/features/order/ui/state/order_state.dart';
import 'package:dimpos_store/features/product/models/cart.dart';
import 'package:dimpos_store/features/product/models/cart_item.dart';
import 'package:dimpos_store/features/product/repositories/member_repository.dart';
import 'package:dimpos_store/utils/logger_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_view_model.g.dart';

@Riverpod(keepAlive: true)
class OrderViewModel extends _$OrderViewModel {
  @override
  FutureOr<OrderState> build() async {
    final orders = await ref.read(orderRepositoryProvider).getOrders();
    if (orders == null) {
      return OrderState();
    }
    final hasMoreData = orders.total! >= 12;
    return OrderState(
      allOrders: orders.items!,
      filteredOrders: orders.items!,
      filterStatus: null, // Default to "All" status
      errorMessage: '',
      isLoading: false,
      hasMoreData: hasMoreData,
      isLoadingMore: false,
      currentPage: 1,
    );
  }

  void setSelectedOrder(Order order) async {
    if (state.value == null) {
      return;
    }
    setLoading(true);
    try {
      final orderDetails =
          await ref.read(orderRepositoryProvider).getOrderById(order.id);
      if (orderDetails != null) {
        state = AsyncData(
          state.value!.copyWith(
            selectedOrder: orderDetails,
            selectedOrderCustomer:
                null, // Reset customer when selecting a new order
          ),
        );
      } else {
        setErrorMessage('Failed to fetch order details');
      }
    } catch (e) {
      setErrorMessage('Error fetching order details: $e');
    } finally {
      setLoading(false);
    }
  }

  void setSelectedOrderCustomer(String customerId) async {
    if (state.value == null) {
      return;
    }
    final customer =
        await ref.read(memberRepositoryProvider).getCustomerById(customerId);
    if (customer != null) {
      state = AsyncData(
        state.value!.copyWith(
          selectedOrderCustomer: customer,
        ),
      );
    }
  }

  // void removeSelectedOrder() async {
  //   if (state.value == null) {
  //     return;
  //   }

  //   if (state.value!.selectedOrder != null) {
  //     state = AsyncData(
  //       state.value!.copyWith(selectedOrder: null, selectedOrderCustomer: null),
  //     );
  //   }
  // }

  void setFilterStatus(int? status) {
    if (state.value == null) {
      return;
    }
    state = AsyncData(
      state.value!.copyWith(
        filterStatus: status,
      ),
    );
    fetchOrders(
      status: status,
      fromDate: state.value!.fromDate,
      toDate: state.value!.toDate,
      isRefresh: true,
    );
  }

  void setDateRange(DateTime? fromDate, DateTime? toDate) {
    if (state.value == null) {
      return;
    }
    state = AsyncData(
      state.value!.copyWith(
        fromDate: fromDate,
        toDate: toDate,
      ),
    );
  }

  void setErrorMessage(String message) {
    if (state.value == null) {
      return;
    }
    state = AsyncData(
      state.value!.copyWith(
        errorMessage: message,
      ),
    );
  }

  void setLoading(bool isLoading) {
    if (state.value == null) {
      return;
    }
    state = AsyncData(
      state.value!.copyWith(
        isLoading: isLoading,
      ),
    );
  }

  void setSelectedOrderLoading(bool isLoading) {
    if (state.value == null) {
      return;
    }
    state = AsyncData(
      state.value!.copyWith(
        isSelectedOrderLoading: isLoading,
      ),
    );
  }

  void setLoadingMore(bool isLoadingMore) {
    if (state.value == null) {
      return;
    }
    state = AsyncData(
      state.value!.copyWith(
        isLoadingMore: isLoadingMore,
      ),
    );
  }

  // Define methods to manipulate the state, e.g., fetch orders, update order status, etc.
  Future<void> fetchOrders({
    int page = 1,
    int pageSize = 10,
    int? status,
    int? type,
    String sortBy = 'createdDate',
    bool isAsc = false,
    bool isRefresh = false,
    bool isNeedSetLoading = true,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (state.value == null) return;

    // Determine which page to fetch
    int targetPage = isRefresh ? 1 : state.value!.currentPage;

    // Set appropriate loading state
    if (isRefresh) {
      setLoading(true);
    } else {
      setLoadingMore(true);
    }
    try {
      final orders = await ref.read(orderRepositoryProvider).getOrders(
            page: targetPage,
            pageSize: state.value!.pageSize,
            status: status,
            type: type,
            sortBy: sortBy,
            isAsc: isAsc,
            fromDate: fromDate,
            toDate: toDate,
          );

      if (orders != null) {
        // Determine if there's more data to load
        final hasMoreData = orders.total! >= state.value!.pageSize;

        // Update the state based on whether this is a refresh or load more
        List<Order> updatedOrders;
        if (isRefresh || !isNeedSetLoading) {
          // Replace existing orders with new ones
          updatedOrders = orders.items!;
        } else {
          // Append new orders to existing ones
          updatedOrders = [...state.value!.allOrders, ...orders.items!];
        }

        state = AsyncData(
          state.value!.copyWith(
            allOrders: updatedOrders,
            filteredOrders: updatedOrders, // Update filtered orders too
            isLoading: false,
            isLoadingMore: false,
            currentPage: targetPage,
            hasMoreData: hasMoreData,
            errorMessage: '', // Clear any previous error
          ),
        );
      } else {
        setErrorMessage('Failed to fetch orders');
      }
    } catch (e) {
      setErrorMessage('Error fetching orders: $e');
    } finally {
      setLoading(false);
      setLoadingMore(false);
    }
  }

  Future<void> loadMoreOrders() async {
    if (state.value == null ||
        state.value!.isLoadingMore ||
        !state.value!.hasMoreData) {
      return; // Don't load if already loading or no more data
    }

    // Increment page number and fetch more orders
    final nextPage = state.value!.currentPage + 1;

    // Update the current page before fetching
    state = AsyncData(
      state.value!.copyWith(
        currentPage: nextPage,
      ),
    );

    // Fetch orders for the next page
    await fetchOrders(
      status: state.value!.filterStatus,
      fromDate: state.value!.fromDate,
      toDate: state.value!.toDate,
      isRefresh: false, // This is a load more operation
    );
  }

  // Method to refresh the entire order list
  Future<void> refreshOrders() async {
    await fetchOrders(
      status: state.value?.filterStatus,
      fromDate: state.value?.fromDate,
      toDate: state.value?.toDate,
      isRefresh: true,
    );
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    // Logic to update order status
  }

  Future<void> createOrder({
    required String brandId,
    String? customerId,
    required String storePaymentMethodConfigId,
    required Cart cart,
    required int paymentMethod,
  }) async {
    if (state.value == null) {
      return;
    }
    setLoading(true);
    try {
      List<CreateOrderItem> orderItems = [];
      for (CartItem item in cart.cartItems ?? []) {
        if (item.extraItems.isNotNullOrEmpty) {
          orderItems.add(
            CreateOrderItem(
              productVariantId: item.productVariantId,
              quantity: item.quantity,
              note: item.notesForItem,
              orderItemSelectedOptions: item.modifierGroupItems
                  ?.map((option) => OrderSelectedOption(
                        modifierOptionId: option.modifierOptionId,
                        relatedComboProductVariantItemId:
                            option.relatedComboProductVariantItemId,
                      ))
                  .toList(),
              orderItemExtras: item.extraItems!
                  .map((extra) => ExtraOrderItem(
                        productVariantId: extra.extraProductVariantId,
                        quantity: extra.quantity,
                      ))
                  .toList(),
            ),
          );
        } else {
          orderItems.add(
            CreateOrderItem(
              productVariantId: item.productVariantId,
              quantity: item.quantity,
              note: item.notesForItem,
              orderItemSelectedOptions: item.modifierGroupItems
                  ?.map((option) => OrderSelectedOption(
                        modifierOptionId: option.modifierOptionId,
                        relatedComboProductVariantItemId:
                            option.relatedComboProductVariantItemId,
                      ))
                  .toList(),
            ),
          );
        }
      }

      final order = await ref.read(orderRepositoryProvider).createOrder(
            brandId: brandId,
            customerId: customerId,
            customerNameSnapshot: cart.customerNameSnapshot,
            note: cart.customerNotesForOrder ?? cart.staffNotesForOrder,
            storePaymentMethodConfigId: storePaymentMethodConfigId,
            orderItems: orderItems,
            promotionRuleIds: cart.promotionsApplied
                ?.map((promotion) => promotion.promotionRuleId)
                .toList(),
            serviceMethod: cart.serviceMethod,
            tableNumberDineIn: cart.takeNumberDineIn,
          );

      if (order != null) {
        final orderDetails =
            await ref.read(orderRepositoryProvider).getOrderById(order.orderId);

        state = AsyncData(
          state.value!.copyWith(
            createdOrder: order.copyWith(
              status: orderDetails?.status,
              paymentMethod: paymentMethod,
              storePaymentMethodConfigId: storePaymentMethodConfigId,
            ),
            isLoading: false,
            errorMessage: '',
          ),
        );
      }
      await refreshOrders();
    } catch (e) {
      setErrorMessage('Error creating order: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  void setAmountPaid(String amountPaid) {
    if (state.value == null || state.value!.createdOrder == null) {
      return;
    }
    providerLogger.d(
      'Setting amount paid: $amountPaid',
    );
    final updatedOrder = state.value!.createdOrder!.copyWith(
      amountPaid: double.tryParse(amountPaid) ?? 0.0,
    );
    state = AsyncData(
      state.value!.copyWith(
        createdOrder: updatedOrder,
      ),
    );
  }

  Future<void> confirmOrderWithCashPayment({
    required String orderId,
    required double amountPaid,
  }) async {
    if (state.value == null) {
      return;
    }
    setLoading(true);
    try {
      await ref.read(orderRepositoryProvider).confirmOrder(
            orderId: orderId,
            amountPaid: amountPaid,
          );
      state = AsyncData(
        state.value!.copyWith(
          createdOrder: null,
          isLoading: false,
          errorMessage: '',
        ),
      );
      await refreshOrders();
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> changeOrderPaymentMethod({
    required String orderId,
    required String oldStorePaymentMethodConfigId,
    required String newStorePaymentMethodConfigId,
    required int paymentMethod,
  }) async {
    if (state.value == null) {
      return;
    }
    setLoading(true);
    try {
      final paymentUrl =
          await ref.read(orderRepositoryProvider).changeOrderPaymentMethod(
                orderId: orderId,
                oldStorePaymentMethodConfigId: oldStorePaymentMethodConfigId,
                newStorePaymentMethodConfigId: newStorePaymentMethodConfigId,
              );
      final updatedOrder = state.value!.createdOrder!.copyWith(
        paymentMethod: paymentMethod,
        paymentUrl: paymentUrl,
        storePaymentMethodConfigId: newStorePaymentMethodConfigId,
      );
      state = AsyncData(
        state.value!.copyWith(
          createdOrder: updatedOrder,
          isLoading: false,
          errorMessage: '',
        ),
      );
      await refreshOrders();
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> completeOrder({
    required String orderId,
  }) async {
    if (state.value == null) {
      return;
    }
    setSelectedOrderLoading(true);
    try {
      await ref.read(orderRepositoryProvider).completeOrder(orderId);
      final orderDetails =
          await ref.read(orderRepositoryProvider).getOrderById(orderId);
      state = AsyncData(
        state.value!.copyWith(
          selectedOrder: orderDetails,
        ),
      );
      await fetchOrders(
        status: state.value?.filterStatus,
        isNeedSetLoading: false,
      );
    } catch (e) {
      rethrow;
    } finally {
      setSelectedOrderLoading(false);
    }
  }

  Future<int> checkOrderStatusWhenPayment({
    required String orderId,
  }) async {
    if (state.value == null) {
      return OrderStatus.PendingPayment.index;
    }
    setLoading(true);
    try {
      final orderDetails =
          await ref.read(orderRepositoryProvider).getOrderById(orderId);
      if ((orderDetails?.status ?? OrderStatus.PendingPayment.index) !=
          OrderStatus.PendingPayment.index) {
        state = AsyncData(
          state.value!.copyWith(
            createdOrder: null,
            isLoading: false,
            errorMessage: '',
          ),
        );
      }
      await refreshOrders();
      return orderDetails?.status ?? OrderStatus.PendingPayment.index;
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> cancelOrder({
    required String orderId,
    required String cancellationReason,
  }) async {
    if (state.value == null) {
      return;
    }
    setSelectedOrderLoading(true);
    try {
      await ref.read(orderRepositoryProvider).cancelOrder(
            orderId: orderId,
            cancellationReason: cancellationReason,
          );
      final orderDetails =
          await ref.read(orderRepositoryProvider).getOrderById(orderId);
      state = AsyncData(
        state.value!.copyWith(
          selectedOrder: orderDetails,
        ),
      );
      await fetchOrders(
        status: state.value?.filterStatus,
        isNeedSetLoading: false,
      );
    } catch (e) {
      rethrow;
    } finally {
      setSelectedOrderLoading(false);
    }
  }

  Future<void> cancelOrderWhenPayment({
    required String orderId,
    required String cancellationReason,
  }) async {
    if (state.value == null) {
      return;
    }
    setLoading(true);
    try {
      await ref.read(orderRepositoryProvider).cancelOrder(
            orderId: orderId,
            cancellationReason: cancellationReason,
          );
      state = AsyncData(
        state.value!.copyWith(
          createdOrder: null,
          isLoading: false,
          errorMessage: '',
        ),
      );
      await refreshOrders();
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> rollBackInventoryManually(String orderId) async {
    if (state.value == null) {
      return;
    }
    setSelectedOrderLoading(true);
    try {
      await ref
          .read(inventoryRepositoryProvider)
          .rollBackInventoryManually(orderId);
      final orderDetails =
          await ref.read(orderRepositoryProvider).getOrderById(orderId);
      state = AsyncData(
        state.value!.copyWith(
          selectedOrder: orderDetails,
        ),
      );
      await fetchOrders(
        status: state.value?.filterStatus,
        isNeedSetLoading: false,
      );
    } catch (e) {
      rethrow;
    } finally {
      setSelectedOrderLoading(false);
    }
  }

  void setStatusSuccessPaymentForOrder() async {
    if (state.value == null) {
      return;
    }
    state = AsyncData(
      state.value!.copyWith(
        isPaymentSuccess: true,
      ),
    );
  }

  void resetStatusSuccessPaymentForOrder() async {
    if (state.value == null) {
      return;
    }
    state = AsyncData(
      state.value!.copyWith(
        isPaymentSuccess: false,
      ),
    );
  }
}
