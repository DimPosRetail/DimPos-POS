import 'package:dimpos_store/features/product/models/rule_action.dart';
import 'package:dimpos_store/features/product/models/rule_condition.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'promotion_rule.freezed.dart';
part 'promotion_rule.g.dart';

@freezed
class PromotionRule with _$PromotionRule {
  const factory PromotionRule({
    required String id,
    // @Default(null) String? brandId,
    required String name,
    String? shortDescription,
    String? description,
    required bool isValid,
    @Default(false) bool isSelected,
    @Default("Active") String status,
    required List<RuleCondition> ruleConditions,
    required RuleAction ruleAction,
  }) = _PromotionRule;
  factory PromotionRule.fromJson(Map<String, dynamic> json) =>
      _$PromotionRuleFromJson(json);
}
