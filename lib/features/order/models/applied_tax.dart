import 'package:freezed_annotation/freezed_annotation.dart';

part 'applied_tax.freezed.dart';
part 'applied_tax.g.dart';

@freezed
class AppliedTax with _$AppliedTax {
  const factory AppliedTax({
    required String id,
    required String orderId,
    required String taxRateId,
    required String taxNameSnapshot,
    required String taxRateSnapshot,
    required String taxBaseAmount,
    required String taxAmountCalculated,
  }) = _AppliedTax;

  factory AppliedTax.fromJson(Map<String, dynamic> json) =>
      _$AppliedTaxFromJson(json);
}