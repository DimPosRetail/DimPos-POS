import 'dart:async';

import 'package:dimpos_store/enums/order_status.dart';
import 'package:dimpos_store/enums/payment_method.dart';
import 'package:dimpos_store/features/order/ui/view_models/order_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

mixin PaymentStatusPolling {
  Timer? _statusCheckTimer;

  void startPaymentStatusPolling({
    required WidgetRef ref,
    required BuildContext context,
    required String orderId,
    required int paymentMethod,
  }) {
    if (paymentMethod != PaymentMethodEnum.qrVietqr.index &&
        paymentMethod != PaymentMethodEnum.qrEdc.index &&
        paymentMethod != PaymentMethodEnum.cardEdc.index &&
        paymentMethod != PaymentMethodEnum.qrPayOs.index) {
      return;
    }

    _statusCheckTimer?.cancel();

    _statusCheckTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) async {
        try {
          final orderStatus = await ref
              .read(orderViewModelProvider.notifier)
              .checkOrderStatusWhenPayment(orderId: orderId);

          if (orderStatus == OrderStatus.Confirmed.index ||
              orderStatus == OrderStatus.ReadyForPickup.index) {
            timer.cancel();
            _statusCheckTimer = null;

            if (context.mounted) {
              toastification.show(
                type: ToastificationType.success,
                style: ToastificationStyle.flatColored,
                title: Text('Thanh toán thành công!'),
                description: Text(
                    'Đơn hàng ${orderId.split('-').last} đã được thanh toán thành công.'),
                autoCloseDuration: const Duration(seconds: 3),
                alignment: Alignment.topRight,
              );
              ref
                  .read(cartViewModelProvider.notifier)
                  .setDraftOrderCode(orderId);
              ref
                  .read(orderViewModelProvider.notifier)
                  .setStatusSuccessPaymentForOrder();
              // context.pop();
            }
          } else if (orderStatus == OrderStatus.Cancelled.index) {
            timer.cancel();
            _statusCheckTimer = null;

            if (context.mounted) {
              toastification.show(
                type: ToastificationType.error,
                style: ToastificationStyle.flatColored,
                title: Text('Thanh toán thất bại!'),
                description: Text(
                    'Đơn hàng ${orderId.split('-').last} đã bị hủy hoặc thanh toán thất bại.'),
                autoCloseDuration: const Duration(seconds: 3),
                alignment: Alignment.topRight,
              );

              context.pop();
            }
          }
        } catch (e) {
          print('Error checking order status: $e');
        }
      },
    );
  }

  void stopPaymentStatusPolling() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
  }

  void onOrderCancelled() {
    stopPaymentStatusPolling();
  }
}
