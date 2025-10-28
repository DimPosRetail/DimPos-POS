import 'package:freezed_annotation/freezed_annotation.dart';

part 'condition_rule.freezed.dart';
part 'condition_rule.g.dart';

@freezed
class ConditionRule with _$ConditionRule {
  const factory ConditionRule({
    required int conditionType,
    required int operator,
    @Default("") String conditionValue,
  }) = _ConditionRule;
  factory ConditionRule.fromJson(Map<String, dynamic> json) =>
      _$ConditionRuleFromJson(json);
}
