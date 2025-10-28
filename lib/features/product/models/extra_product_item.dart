import 'package:freezed_annotation/freezed_annotation.dart';

part 'extra_product_item.freezed.dart';
part 'extra_product_item.g.dart';

@freezed
class ExtraProductItem with _$ExtraProductItem {
  const factory ExtraProductItem({
    required String extraProductVariantId,
    required String extraProductVariantNameSnapshot,
    required double unitPriceAtAdditionSnapshot,
    required String relatedProductVariantId,
    required int quantity,
  }) = _ExtraProductItem;

  factory ExtraProductItem.fromJson(Map<String, dynamic> json) =>
      _$ExtraProductItemFromJson(json);
}
