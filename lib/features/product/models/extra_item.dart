import 'package:freezed_annotation/freezed_annotation.dart';

part 'extra_item.freezed.dart';
part 'extra_item.g.dart';

@freezed
class ExtraItem with _$ExtraItem {
  const factory ExtraItem({
    required String id,
    required String code,
    required String name,
    String? description,
    required double price,
    required int displayOrder,
    required bool isActive,
    @Default(false) bool isSelected,
    @Default(1) int quantity,
  }) = _ExtraItem;

  factory ExtraItem.fromJson(Map<String, dynamic> json) =>
      _$ExtraItemFromJson(json);
}
