import 'package:dimpos_store/features/product/models/modifier_option.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'modifier_group.freezed.dart';
part 'modifier_group.g.dart';

@freezed
class ModifierGroup with _$ModifierGroup {
  const factory ModifierGroup({
    required String id,
    required String name,
    String? description,
    required int displayOrder,
    required bool isActive,
    required String brandId,
    required int selectedType,
    required List<String> productVariantIds,
    List<ModifierOption>? modifierOptions,
  }) = _ModifierGroup;

  factory ModifierGroup.fromJson(Map<String, dynamic> json) =>
      _$ModifierGroupFromJson(json);
}
