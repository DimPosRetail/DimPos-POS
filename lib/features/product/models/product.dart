import 'package:dimpos_store/features/product/models/combo_item.dart';
import 'package:dimpos_store/features/product/models/extra_item.dart';
import 'package:dimpos_store/features/product/models/product_variant.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String code,
    required String name,
    required String description,
    required String imageUrl,
    required double price,
    required String categoryId,
    List<ProductVariant>? productVariants,
    List<ExtraItem>? extraItemProductVariants,
    List<ComboItem>? comboItems,
  }) = _Product;
  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
