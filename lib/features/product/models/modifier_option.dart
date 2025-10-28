import 'package:freezed_annotation/freezed_annotation.dart';

part 'modifier_option.freezed.dart';
part 'modifier_option.g.dart';

@freezed
class ModifierOption with _$ModifierOption {
  const factory ModifierOption({
    required String id,
    required String name,
    String? description,
    required bool isActive,
    // required double priceDelta,
    @Default(false) bool isSelected,
  }) = _ModifierOption;

  factory ModifierOption.fromJson(Map<String, dynamic> json) =>
      _$ModifierOptionFromJson(json);
}
