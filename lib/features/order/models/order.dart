import 'package:dimpos_store/features/order/models/order_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required int type,
    required int status,
    String? customerNameSnapshot,
    String? customerLoyaltyCardNumberSnapshot,
    required double totalAmount,
    double? subTotalAmount,
    double? discountAmount,
    double? taxAmount,
    double? amountPaid,
    double? cashRoundingAmount,
    String? note,
    required DateTime createdDate,
    required DateTime? completedAt,
    int? tableNumberDineIn,
    DateTime? pickupTime,
    required bool isNeedToUpdateInventory,
    @Default([]) List<OrderItem> orderItems,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
