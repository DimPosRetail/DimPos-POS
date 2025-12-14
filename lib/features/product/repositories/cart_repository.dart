import 'package:dimpos_store/enums/api_url.dart';
import 'package:dimpos_store/features/common/models/base_response.dart';
import 'package:dimpos_store/features/product/models/cart.dart';
import 'package:dimpos_store/features/product/models/cart_applied_promotion_detail.dart';
import 'package:dimpos_store/features/product/models/extra_product_item.dart';
import 'package:dimpos_store/features/product/models/modifier_group_item.dart';
import 'package:dimpos_store/utils/request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_repository.g.dart';

@riverpod
CartRepository cartRepository(Ref ref) {
  return const CartRepository();
}

class CartRepository {
  const CartRepository();

  Future<List<Cart>?> getCarts() async {
    final response = await apiClient.getClient(ApiUrl.basket).get(
          '/carts',
        );
    final carts = BaseResponse<List<Cart>?>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((e) => Cart.fromJson(e as Map<String, dynamic>))
          .toList(),
    ).data;
    return carts;
  }

  Future<void> addNewCart({
    required String brandId,
    required double taxRate,
  }) async {
    await apiClient.getClient(ApiUrl.basket).post(
      '/carts',
      data: {
        "brandId": brandId,
        "taxRate": taxRate,
      },
    );
  }

  Future<void> removeCart(String cartId) async {
    await apiClient.getClient(ApiUrl.basket).delete(
          '/carts/$cartId',
        );
  }

  Future<void> updateCartItem({
    required String cartId,
    required String cartItemId,
    required int quantity,
    List<ModifierGroupItem> modifierGroupItems = const [],
    List<ExtraProductItem>? extraProductItems,
    String? notesForItem,
  }) async {
    await apiClient.getClient(ApiUrl.basket).patch(
      '/carts/$cartId/cart-items/$cartItemId',
      data: {
        "quantity": quantity,
        "modifierGroupItems":
            modifierGroupItems.map((e) => e.toJson()).toList(),
        "extraItems": extraProductItems?.map((e) => e.toJson()).toList(),
        "notesForItem": notesForItem,
      },
    );
  }

  Future<void> addProductToCart({
    required String cartId,
    required String productVariantId,
    required String productNameSnapshot,
    required String productVariantNameSnapshot,
    required int quantity,
    required double unitPriceAtAdditionSnapshot,
    String? productImageUrlSnapshot,
    String? notesForItem,
    List<ModifierGroupItem> modifierGroupItems = const [],
    List<ExtraProductItem>? extraProductItems,
  }) async {
    await apiClient.getClient(ApiUrl.basket).post(
      '/carts/$cartId/cart-items',
      data: {
        "productVariantId": productVariantId,
        "productNameSnapshot": productNameSnapshot,
        "productVariantNameSnapshot": productVariantNameSnapshot,
        "quantity": quantity,
        "unitPriceAtAdditionSnapshot": unitPriceAtAdditionSnapshot,
        "productImageUrlSnapshot": productImageUrlSnapshot,
        "notesForItem": notesForItem,
        "modifierGroupItems":
            modifierGroupItems.map((e) => e.toJson()).toList(),
        "extraItems": extraProductItems?.map((e) => e.toJson()).toList(),
      },
    );
  }

  Future<void> applyPromotionToCart({
    required String cartId,
    required CartAppliedPromotionDetail promotion,
  }) async {
    await apiClient.getClient(ApiUrl.basket).post(
      '/carts/$cartId/promotions',
      data: {
        "promotionRuleId": promotion.promotionRuleId,
        "promotionNameSnapshot": promotion.promotionNameSnapshot,
        // "discountValueCalculated": promotion.discountValueSnapshot,ssss
        "actionType": promotion.actionType,
        "actionValue": promotion.actionValue,
        "conditionRules":
            promotion.conditionRules.map((e) => e.toJson()).toList(),
        "targetCriteriaForItemAction": promotion.targetCriteriaForItemAction,
        "maxDiscountAmountForPercentage":
            promotion.ruleAction?.maxDiscountAmountForPercentage ?? 0.0,
        "applicableCartItemIds": promotion.applicableCartItemIds,
      },
    );
  }

  Future<void> removePromotionFromCart({
    required String cartId,
    required List<String> promotionIds,
  }) async {
    await apiClient
        .getClient(ApiUrl.basket)
        .delete('/carts/$cartId/promotions', data: {
      "promotionIds": promotionIds,
    });
  }

  Future<void> updateCart({
    required String cartId,
    int? serviceMethod,
    int? takeNumberDineIn,
    String? customerLoyaltyCardNumberSnapshot,
  }) async {
    await apiClient.getClient(ApiUrl.basket).patch(
      '/carts/$cartId',
      data: {
        "serviceMethod": serviceMethod,
        "takeNumberDineIn": takeNumberDineIn,
        "customerLoyaltyCardNumberSnapshot": customerLoyaltyCardNumberSnapshot,
      },
    );
  }
}
