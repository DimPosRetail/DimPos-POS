import 'package:freezed_annotation/freezed_annotation.dart';

part 'rule_action.freezed.dart';
part 'rule_action.g.dart';

@freezed
class RuleAction with _$RuleAction {
  const factory RuleAction({
    required String id,
    required int actionType,
    @Default("") String value,
    @Default([]) List<String> targetCriteriaForItemAction,
    double? maxDiscountAmountForPercentage,
  }) = _RuleAction;
  factory RuleAction.fromJson(Map<String, dynamic> json) =>
      _$RuleActionFromJson(json);
}
