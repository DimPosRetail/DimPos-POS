import 'package:dimpos_store/enums/api_url.dart';
import 'package:dimpos_store/features/common/models/base_response.dart';
import 'package:dimpos_store/features/product/models/payment_method.dart';
import 'package:dimpos_store/utils/request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_method_repository.g.dart';

@riverpod
PaymentMethodRepository paymentMethodRepository(Ref ref) {
  return const PaymentMethodRepository();
}

class PaymentMethodRepository {
  const PaymentMethodRepository();

  Future<List<PaymentMethod>?> getPaymentMethods() async {
    final response = await apiClient.getClient(ApiUrl.store).get(
          '/store-payment-method-configs/pos',
        );
    final paymentMethods = BaseResponse<List<PaymentMethod>?>.fromJson(
      response.data,
      (json) => (json as List)
          .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
          .toList(),
    ).data;
    return paymentMethods;
  }
}
