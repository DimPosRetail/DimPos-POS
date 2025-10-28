import 'package:dimpos_store/features/product/models/modifier_group.dart';
import 'package:dimpos_store/features/product/models/product_variant.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'combo_item.freezed.dart';
part 'combo_item.g.dart';

@freezed
class ComboItem with _$ComboItem {
  const factory ComboItem({
    required String id,
    required int displayOrder,
    required int quantity,
    required ProductVariant productVariant,
    List<ModifierGroup>? modifierGroups,
  }) = _ComboItem;

  factory ComboItem.fromJson(Map<String, dynamic> json) =>
      _$ComboItemFromJson(json);
}
