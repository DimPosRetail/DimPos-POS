import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_variant.freezed.dart';
part 'product_variant.g.dart';

@freezed
class ProductVariant with _$ProductVariant {
  const factory ProductVariant({
    required String id,
    required String code,
    required String sku,
    required String name,
    required double price,
    required bool isActive,
    String? size,
    required int displayOrder,
    bool? isSelected,
  }) = _ProductVariant;

  factory ProductVariant.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantFromJson(json);
}
