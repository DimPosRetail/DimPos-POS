import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_shift_state.freezed.dart';
part 'financial_shift_state.g.dart';

@freezed
class FinancialShiftState with _$FinancialShiftState {
  const factory FinancialShiftState({
    @Default(false) bool isShiftOpen,
    String? financialShiftId,
    @Default([]) List<int> takedTableNumber,
  }) = _FinancialShiftState;

  factory FinancialShiftState.fromJson(Map<String, dynamic> json) =>
      _$FinancialShiftStateFromJson(json);
}
