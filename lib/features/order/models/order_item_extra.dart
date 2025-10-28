import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item_extra.freezed.dart';
part 'order_item_extra.g.dart';

@freezed
class OrderItemExtra with _$OrderItemExtra {
  const factory OrderItemExtra({
    required String productVariantId,
    required String productNameSnapshot,
    required String productVariantNameSnapshot,
    required int quantity,
    required double unitPriceSnapshot,
  }) = _OrderItemExtra;

  factory OrderItemExtra.fromJson(Map<String, dynamic> json) =>
      _$OrderItemExtraFromJson(json);
}
