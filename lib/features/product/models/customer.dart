import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String accountId,
    required String brandId,
    required String currentLoyaltyTierName,
    required DateTime currentTierAssignedAt,
    required DateTime nextTierReviewDate,
    required double lifetimeSpendAmountAtBrand,
    required double periodSpendAmountAtBrand,
    required int lifetimeOrderCountAtBrand,
    required int periodOrderCountAtBrand,
    required DateTime lastPurchaseDateAtBrand,
    required DateTime firstPurchaseDateAtBrand,
    required bool optInMarketingAtBrand,
    required DateTime joinedBrandAt,
    required bool isActiveProfileForBrand,
    required String fullName,
    required String gender,
    required DateTime birthDate,
    required String phone,
  }) = _Customer;
  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}
