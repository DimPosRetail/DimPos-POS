import 'package:dimpos_store/features/product/models/customer.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership_state.freezed.dart';
part 'membership_state.g.dart';

@freezed
class MembershipState with _$MembershipState {
  const factory MembershipState({
    // @Default("") String searchValue,
    @Default([]) List<Customer> searchCustomers,
  }) = _MembershipState;

  factory MembershipState.fromJson(Map<String, dynamic> json) =>
      _$MembershipStateFromJson(json);
}
