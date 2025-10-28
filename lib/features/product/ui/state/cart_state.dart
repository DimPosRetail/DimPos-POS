import 'package:dimpos_store/features/product/models/cart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_state.freezed.dart';
part 'cart_state.g.dart';

@freezed
class CartState with _$CartState {
  const factory CartState({
    List<Cart>? carts,
    @Default(0) int selectedCartIndex,
    @Default(false) bool isUpdatingCart,
    Cart? draftOrder,
    int? draftCartIndex,
  }) = _CartState;
  factory CartState.fromJson(Map<String, dynamic> json) =>
      _$CartStateFromJson(json);
}
