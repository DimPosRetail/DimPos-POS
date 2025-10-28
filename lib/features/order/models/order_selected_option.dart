import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_selected_option.freezed.dart';
part 'order_selected_option.g.dart';

@freezed
class OrderSelectedOption with _$OrderSelectedOption {
  const factory OrderSelectedOption({
    required String modifierOptionId,
    String? relatedComboProductVariantItemId,
  }) = _OrderSelectedOption;

  factory OrderSelectedOption.fromJson(Map<String, dynamic> json) =>
      _$OrderSelectedOptionFromJson(json);
}
