import 'package:dimpos_store/enums/api_url.dart';
import 'package:dimpos_store/features/common/models/base_response.dart';
import 'package:dimpos_store/features/product/models/promotion_rule.dart';
import 'package:dimpos_store/utils/request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'promotion_rule_repository.g.dart';

@riverpod
PromotionRuleRepository promotionRuleRepository(Ref ref) {
  return const PromotionRuleRepository();
}

class PromotionRuleRepository {
  const PromotionRuleRepository();

  Future<List<PromotionRule>?> getPromotionRules({
    required String cartId,
  }) async {
    final response = await apiClient.getClient(ApiUrl.promotion).get(
          '/promotion-rules/carts/$cartId',
        );
    final promotionRules = BaseResponse<List<PromotionRule>?>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((e) => PromotionRule.fromJson(e as Map<String, dynamic>))
          .toList(),
    ).data;

    return promotionRules;
  }
}
