import 'package:dimpos_store/features/product/models/cart_applied_promotion_detail.dart';
import 'package:dimpos_store/features/product/models/cart_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

@freezed
class Cart with _$Cart {
  const factory Cart({
    required String id,
    String? storeId,
    String? branchId,
    String? posDeviceId,
    String? staffAccountIdCreating,
    String? customerIdLink,
    String? customerNameSnapshot,
    // String? modeOfService,
    required int serviceMethod,
    int? takeNumberDineIn,
    DateTime? pickupTimeRequested,
    required int status,
    required double subtotalAmount,
    required double totalItemDiscountAmount,
    required double orderLevelDiscountAmount,
    required double totalTaxAmount,
    double? totalServiceChargeAmount,
    required double finalTotalAmount,
    String? staffNotesForOrder,
    String? customerNotesForOrder,
    String? selectedPaymentMethodConfigId,
    required int itemCount,
    required int totalQuantityOfItems,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expireAt,
    @Default([]) List<CartItem>? cartItems,
    @Default([]) List<CartAppliedPromotionDetail>? promotionsApplied,
    @Default("") String draftOrderCode,
  }) = _Cart;
  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
}

// double? _stringToDouble(String? input) =>
//     input == null ? null : double.tryParse(input);
// String? _doubleToString(double? input) => input?.toString();
