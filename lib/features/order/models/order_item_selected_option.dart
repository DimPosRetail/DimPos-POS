import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item_selected_option.freezed.dart';
part 'order_item_selected_option.g.dart';

@freezed
class OrderItemSelectedOption with _$OrderItemSelectedOption {
  const factory OrderItemSelectedOption({
    required String id,
    required String modifierGroupId,
    required String modifierGroupSnapshot,
    required String modifierOptionId,
    required String modifierOptionSnapshot,
  }) = _OrderItemSelectedOption;

  factory OrderItemSelectedOption.fromJson(Map<String, dynamic> json) =>
      _$OrderItemSelectedOptionFromJson(json);
}
