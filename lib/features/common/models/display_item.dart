import 'package:freezed_annotation/freezed_annotation.dart';

part 'display_item.freezed.dart';
part 'display_item.g.dart';

@Freezed(genericArgumentFactories: true)
class DisplayItem with _$DisplayItem {
  const factory DisplayItem({
    required String display,
    int? value,
  }) = _DisplayItem;

  factory DisplayItem.fromJson(Map<String, dynamic> json) =>
      _$DisplayItemFromJson(json);
}
