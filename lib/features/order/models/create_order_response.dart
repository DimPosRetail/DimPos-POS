import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_order_response.freezed.dart';
part 'create_order_response.g.dart';

@freezed
class CreateOrderResponse with _$CreateOrderResponse {
  const factory CreateOrderResponse({
    required String orderId,
    String? paymentUrl,
    int? status,
    @Default(0) int paymentMethod,
    @Default(0) double amountPaid,
    @Default("") String storePaymentMethodConfigId,
  }) = _CreateOrderResponse;
  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderResponseFromJson(json);
}
