import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_method.freezed.dart';
part 'payment_method.g.dart';

@freezed
class PaymentMethod with _$PaymentMethod {
  const factory PaymentMethod({
    required String id,
    required String systemPaymentMethodId,
    required String name,
    required String code,
    String? description,
    required int paymentMethod,
    String? logoUrl,
  }) = _PaymentMethod;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);
}
