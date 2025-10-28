import 'package:freezed_annotation/freezed_annotation.dart';

part 'tax_rate.freezed.dart';
part 'tax_rate.g.dart';

@freezed
class TaxRate with _$TaxRate {
  const factory TaxRate({
    required String id,
    required String name,
    required double rate,
  }) = _TaxRate;
  factory TaxRate.fromJson(Map<String, dynamic> json) =>
      _$TaxRateFromJson(json);
}
