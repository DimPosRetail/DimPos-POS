import 'package:freezed_annotation/freezed_annotation.dart';

part 'extra_order_item.freezed.dart';
part 'extra_order_item.g.dart';

@freezed
class ExtraOrderItem with _$ExtraOrderItem {
  const factory ExtraOrderItem({
    required String productVariantId,
    required int quantity,
  }) = _ExtraOrderItem;

  factory ExtraOrderItem.fromJson(Map<String, dynamic> json) =>
      _$ExtraOrderItemFromJson(json);
}
