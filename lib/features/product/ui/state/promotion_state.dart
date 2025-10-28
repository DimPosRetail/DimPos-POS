import 'package:dimpos_store/features/product/models/promotion_rule.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'promotion_state.freezed.dart';
part 'promotion_state.g.dart';

@freezed
class PromotionState with _$PromotionState {
  const factory PromotionState({
    List<PromotionRule>? promotionRules,
    @Default(false) bool isLoading,
    @Default(false) bool isWarning,
  }) = _PromotionState;

  factory PromotionState.fromJson(Map<String, dynamic> json) =>
      _$PromotionStateFromJson(json);
}
