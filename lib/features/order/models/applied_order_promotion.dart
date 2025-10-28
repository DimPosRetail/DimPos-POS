import 'package:freezed_annotation/freezed_annotation.dart';

part 'applied_order_promotion.freezed.dart';
part 'applied_order_promotion.g.dart';

@freezed
class AppliedOrderPromotion with _$AppliedOrderPromotion {
  const factory AppliedOrderPromotion({
    required String id,
    required String orderId,
    required String promotionRuleId,
    required String promotionNameSnapshot,
    required String promotionTypeSnapshot,
    required String discountAmountApplied,
    required String descriptionOfBenefitSnapshot,
    required String sourceVoucherCodeUsedSnapshot,
    required String applicableOrderItemIdsSnapshot,
    required String appliedAt,
  }) = _AppliedOrderPromotion;

  factory AppliedOrderPromotion.fromJson(Map<String, dynamic> json) =>
      _$AppliedOrderPromotionFromJson(json);
}