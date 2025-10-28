import 'package:freezed_annotation/freezed_annotation.dart';

part 'modifier_group_item.freezed.dart';
part 'modifier_group_item.g.dart';

@freezed
class ModifierGroupItem with _$ModifierGroupItem {
  const factory ModifierGroupItem({
    required String modifierGroupId,
    required String modifierOptionId,
    @Default("") String modifierGroupNameSnapshot,
    @Default("") String modifierOptionSnapshot,
    // required double priceDeltaSnapshot,
    String? relatedComboProductVariantItemId,
    String? relatedComboProductVariantItemName,
  }) = _ModifierGroupItem;
  factory ModifierGroupItem.fromJson(Map<String, dynamic> json) =>
      _$ModifierGroupItemFromJson(json);
}
