import 'package:dimpos_store/features/product/models/payment_method.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_method_state.freezed.dart';
part 'payment_method_state.g.dart';

@freezed
class PaymentMethodState with _$PaymentMethodState {
  const factory PaymentMethodState({
    @Default([]) List<PaymentMethod> paymentMethods,
    @Default(0) int selectedPaymentMethod,
  }) = _PaymentMethodState;

  factory PaymentMethodState.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodStateFromJson(json);
}