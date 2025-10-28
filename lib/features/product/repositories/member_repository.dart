import 'package:dimpos_store/features/product/models/customer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member_repository.g.dart';

@riverpod
MemberRepository memberRepository(Ref ref) {
  return const MemberRepository();
}

class MemberRepository {
  const MemberRepository();

  Future<List<Customer>?> getCustomersByPhoneNumber(String phoneNumber) async {
    // final response = await apiClient.getClient(ApiUrl.menu).get(
    //       '/',
    //     );

    // final customer = BaseResponse<Customer>.fromJson(response.data,
    //     (json) => Customer.fromJson(json as Map<String, dynamic>)).data;
    await Future.delayed(const Duration(seconds: 1)); // mô phỏng API delay
    final customers = List<Customer>.generate(
      10,
      (index) => Customer(
        id: "cus_$index",
        accountId: "acc_$index",
        brandId: "brand_001",
        currentLoyaltyTierName: "Silver",
        currentTierAssignedAt: DateTime(2024, 1, 1),
        nextTierReviewDate: DateTime(2025, 1, 1),
        lifetimeSpendAmountAtBrand: (index + 1) * 1000000.0,
        periodSpendAmountAtBrand: (index + 1) * 500000.0,
        lifetimeOrderCountAtBrand: (index + 1) * 5,
        periodOrderCountAtBrand: (index + 1) * 2,
        lastPurchaseDateAtBrand:
            DateTime(2025, 5, (index % 28 + 1)), // 2025-05-01..28
        firstPurchaseDateAtBrand:
            DateTime(2022, 1, (index % 28 + 1)), // giả lập mốc mua đầu
        optInMarketingAtBrand: index % 2 == 0,
        joinedBrandAt: DateTime(2021, 6, (index % 28 + 1)),
        isActiveProfileForBrand: true,
        fullName: "Customer $index",
        gender: index % 2 == 0 ? "male" : "female",
        birthDate: DateTime(1990 + (index % 10), (index % 12) + 1, 15),
        phone: "09000000${index}",
      ),
    );

    return customers;
  }

  Future<Customer?> getCustomerById(String id) async {
    // final response = await apiClient.getClient(ApiUrl.menu).get(
    //       '/',
    //     );

    // final customer = BaseResponse<Customer>.fromJson(response.data,
    //     (json) => Customer.fromJson(json as Map<String, dynamic>)).data;
    await Future.delayed(const Duration(seconds: 1)); // mô phỏng API delay
    final customers = List<Customer>.generate(
      1,
      (index) => Customer(
        id: "cus_$index",
        accountId: "acc_$index",
        brandId: "brand_001",
        currentLoyaltyTierName: "Silver",
        currentTierAssignedAt: DateTime(2024, 1, 1),
        nextTierReviewDate: DateTime(2025, 1, 1),
        lifetimeSpendAmountAtBrand: (index + 1) * 1000000.0,
        periodSpendAmountAtBrand: (index + 1) * 500000.0,
        lifetimeOrderCountAtBrand: (index + 1) * 5,
        periodOrderCountAtBrand: (index + 1) * 2,
        lastPurchaseDateAtBrand:
            DateTime(2025, 5, (index % 28 + 1)), // 2025-05-01..28
        firstPurchaseDateAtBrand:
            DateTime(2022, 1, (index % 28 + 1)), // giả lập mốc mua đầu
        optInMarketingAtBrand: index % 2 == 0,
        joinedBrandAt: DateTime(2021, 6, (index % 28 + 1)),
        isActiveProfileForBrand: true,
        fullName: "Customer $index",
        gender: index % 2 == 0 ? "male" : "female",
        birthDate: DateTime(1990 + (index % 10), (index % 12) + 1, 15),
        phone: "09000000${index}",
      ),
    );

    return customers[0];
  }
}
