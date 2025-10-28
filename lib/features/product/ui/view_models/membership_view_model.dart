import 'package:dimpos_store/extensions/iterable_extension.dart';
import 'package:dimpos_store/features/product/models/customer.dart';
import 'package:dimpos_store/features/product/repositories/member_repository.dart';
import 'package:dimpos_store/features/product/ui/state/membership_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'membership_view_model.g.dart';

@riverpod
class MembershipViewModel extends _$MembershipViewModel {
  @override
  FutureOr<MembershipState> build(String? cartCustomerAppliedId) async {
    if (cartCustomerAppliedId != null) {
      var customer = await ref
          .read(memberRepositoryProvider)
          .getCustomerById(cartCustomerAppliedId);
      if (customer != null) {
        return MembershipState(searchCustomers: [customer]);
      }
    }
    return const MembershipState(searchCustomers: []);
  }

  Future<void> searchCustomersByPhone(
      String? cartCustomerAppliedId, String phoneNumber) async {
    try {
      state = const AsyncValue.loading(); // Đặt trạng thái loading

      Customer? currentCustomer;
      List<Customer>? searchCustomers;

      if (cartCustomerAppliedId != null) {
        currentCustomer = await ref
            .read(memberRepositoryProvider)
            .getCustomerById(cartCustomerAppliedId);
      }

      searchCustomers = await ref
          .read(memberRepositoryProvider)
          .getCustomersByPhoneNumber(phoneNumber);

      if (currentCustomer != null) {
        if (searchCustomers.isNotNullOrEmpty) {
          var fixSearchCustomers = searchCustomers!.where(
            (e) => (e.id != currentCustomer!.id),
          );
          state = AsyncValue.data(MembershipState(
              searchCustomers: [currentCustomer, ...fixSearchCustomers]));
        } else {
          state = AsyncValue.data(
              MembershipState(searchCustomers: [currentCustomer]));
        }
      } else {
        state = AsyncValue.data(
            MembershipState(searchCustomers: searchCustomers ?? []));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st); // Đừng quên bắt lỗi
    }
  }

  Future<Customer?> findCustomerById(String id) async {
    var customer = await ref.read(memberRepositoryProvider).getCustomerById(id);
    return customer;
  }
}
