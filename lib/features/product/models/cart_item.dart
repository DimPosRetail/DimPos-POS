import 'package:dimpos_store/features/product/models/extra_product_item.dart';
import 'package:dimpos_store/features/product/models/modifier_group_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required String id,
    required String cartId,
    required String productVariantId,
    @Default("") String productNameSnapshot,
    @Default("") String productVariantNameSnapshot,
    @Default(1) int quantity,
    required double unitPriceAtAdditionSnapshot,
    required double itemSubtotalAmount,
    // @Default(0.0) double itemSpecificDiscountAmount,
    // required double itemFinalPrice,
    String? productImageUrlSnapshot,
    String? notesForItem,
    required DateTime addedAt,
    List<ModifierGroupItem>? modifierGroupItems,
    List<ExtraProductItem>? extraItems,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}

// // ------------------------------
// // Selected Options (non-priced)
// // ------------------------------
// @freezed
// class CartItemSelectedOption with _$CartItemSelectedOption {
//   const factory CartItemSelectedOption({
//     required String modifierGroupId,
//     required String modifierOptionId,
//     required String modifierGroupNameSnapshot,
//     required String modifierOptionSnapshot,
//   }) = _CartItemSelectedOption;

//   factory CartItemSelectedOption.fromJson(Map<String, dynamic> json) =>
//       _$CartItemSelectedOptionFromJson(json);
// }

// // ------------------------------
// // JSON conversion helpers
// // ------------------------------

// List<CartItemSelectedOption> _parseSelectedOptions(dynamic json) {
//   if (json is String) {
//     final decoded = jsonDecode(json);
//     if (decoded is List) {
//       return decoded
//           .map((e) =>
//               CartItemSelectedOption.fromJson(Map<String, dynamic>.from(e)))
//           .toList();
//     }
//   }
//   return [];
// }

// String _serializeSelectedOptions(List<CartItemSelectedOption> options) {
//   final mapped = options.map((e) => e.toJson()).toList();
//   return jsonEncode(mapped);
// }
