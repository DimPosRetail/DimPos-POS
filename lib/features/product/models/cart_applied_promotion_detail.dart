import 'package:dimpos_store/features/product/models/condition_rule.dart';
import 'package:dimpos_store/features/product/models/rule_action.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_applied_promotion_detail.freezed.dart';
part 'cart_applied_promotion_detail.g.dart';

@freezed
class CartAppliedPromotionDetail with _$CartAppliedPromotionDetail {
  const factory CartAppliedPromotionDetail({
    required String id,
    required String promotionRuleId,
    @Default("") String promotionNameSnapshot,
    required double discountValueCalculated,
    List<String>? applicableCartItemIds,
    required int actionType,
    @Default("") String actionValue,
    required DateTime createdAt,
    List<String>? targetCriteriaForItemAction,
    double? taxDiscountAmountForPercentage,
    required List<ConditionRule> conditionRules,
    RuleAction? ruleAction,

    // required String promotionTypeSnapshot,
    // @Default("") String promotionShortDescriptionSnapshot,
    // required double discountValueCalculated,
    // String? descriptionOfBenefit,
    // @Default([]) List<String> appliedVoucherCodes,
  }) = _CartAppliedPromotionDetail;

  factory CartAppliedPromotionDetail.fromJson(Map<String, dynamic> json) =>
      _$CartAppliedPromotionDetailFromJson(json);
}
