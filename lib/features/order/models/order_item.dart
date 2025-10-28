import 'package:dimpos_store/features/order/models/order_item_selected_option.dart';
import 'package:dimpos_store/features/order/models/order_item_extra.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item.freezed.dart';
part 'order_item.g.dart';

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String id,
    required String productVariantNameSnapshot,
    required int quantity,
    required double unitPriceSnapshot,
    required double totalPriceBeforeItemDiscount,
    String? note,
    @Default([]) List<OrderItemSelectedOption> orderItemSelectedOptions,
    @Default([]) List<OrderItemExtra> orderItemExtras,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}
