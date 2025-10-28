import 'package:dimpos_store/features/product/repositories/payment_method_repository.dart';
import 'package:dimpos_store/features/product/ui/state/payment_method_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_view_model.g.dart';

@riverpod
class PaymentViewModel extends _$PaymentViewModel {
  @override
  FutureOr<PaymentMethodState> build() async {
    final paymentMethods =
        await ref.read(paymentMethodRepositoryProvider).getPaymentMethods();
    if (paymentMethods == null) return const PaymentMethodState();
    return PaymentMethodState(
        paymentMethods: paymentMethods, selectedPaymentMethod: 0);
  }

  void setSelectedPaymentMethod(int index) {
    final paymentMethods = state.value?.paymentMethods ?? [];
    if (state.value == null) {
      return;
    }
    state = AsyncData(
      state.value!.copyWith(
          paymentMethods: paymentMethods, selectedPaymentMethod: index),
    );
  }
}
