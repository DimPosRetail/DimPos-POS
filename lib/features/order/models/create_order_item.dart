import 'package:dimpos_store/features/order/models/extra_order_item.dart';
import 'package:dimpos_store/features/order/models/order_selected_option.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_order_item.freezed.dart';
part 'create_order_item.g.dart';

@freezed
class CreateOrderItem with _$CreateOrderItem {
  const factory CreateOrderItem({
    required String productVariantId,
    required int quantity,
    String? note,
    List<OrderSelectedOption>? orderItemSelectedOptions,
    List<ExtraOrderItem>? orderItemExtras,
  }) = _CreateOrderItem;

  factory CreateOrderItem.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderItemFromJson(json);
}
