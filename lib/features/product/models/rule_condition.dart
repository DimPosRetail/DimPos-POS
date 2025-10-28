import 'package:freezed_annotation/freezed_annotation.dart';

part 'rule_condition.freezed.dart';
part 'rule_condition.g.dart';

@freezed
class RuleCondition with _$RuleCondition {
  const factory RuleCondition({
    required String id,
    required int conditionType,
    required int operator,
    @Default("") String value,
  }) = _RuleCondition;

  factory RuleCondition.fromJson(Map<String, dynamic> json) =>
      _$RuleConditionFromJson(json);
}
