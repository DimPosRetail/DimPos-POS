import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_shift.freezed.dart';
part 'financial_shift.g.dart';

@freezed
class FinancialShift with _$FinancialShift {
  const factory FinancialShift({
    required String id,
    required DateTime openingTimestamp,
    required String openedByAccountId,
    required double openingCashExpected,
    required double openingCashActual,
    String? openingDifferenceReason,
    DateTime? closingTimestamp,
    String? closedByAccountId,
    double? totalGrossSalesInShift,
    double? totalNetSalesInShift,
    double? totalTaxInShift,
    double? totalDiscountInShift,
    double? totalCashRoundingInShift,
    required int status,
    required DateTime createdDate,
    DateTime? lastModifiedDate,
  }) = _FinancialShift;

  factory FinancialShift.fromJson(Map<String, dynamic> json) =>
      _$FinancialShiftFromJson(json);
}
