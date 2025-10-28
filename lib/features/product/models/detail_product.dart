import 'package:dimpos_store/features/product/models/combo_item.dart';
import 'package:dimpos_store/features/product/models/extra_item.dart';
import 'package:dimpos_store/features/product/models/modifier_group.dart';
import 'package:dimpos_store/features/product/models/product_variant.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_product.freezed.dart';
part 'detail_product.g.dart';

@freezed
class DetailProduct with _$DetailProduct {
  const factory DetailProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    int? quantity,
    double? totalPrice,
    String? imageUrl,
    List<ProductVariant>? variants,
    List<ExtraItem>? extraItemProductVariants,
    List<ComboItem>? comboItems,
    List<ModifierGroup>? modifierGroups,
    String? notesForItem,
    String? cartItemId,
    @Default(false) bool isUpdated,
  }) = _DetailProduct;

  factory DetailProduct.fromJson(Map<String, dynamic> json) =>
      _$DetailProductFromJson(json);
}
