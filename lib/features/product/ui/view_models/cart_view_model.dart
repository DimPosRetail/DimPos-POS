import 'package:dimpos_store/enums/mode_of_service.dart';
import 'package:dimpos_store/extensions/iterable_extension.dart';
import 'package:dimpos_store/features/product/models/cart.dart';
import 'package:dimpos_store/features/product/models/cart_applied_promotion_detail.dart';
import 'package:dimpos_store/features/product/models/cart_item.dart';
import 'package:dimpos_store/features/product/models/condition_rule.dart';
import 'package:dimpos_store/features/product/models/detail_product.dart';
import 'package:dimpos_store/features/product/models/extra_product_item.dart';
import 'package:dimpos_store/features/product/models/modifier_group_item.dart';
import 'package:dimpos_store/features/product/models/promotion_rule.dart';
import 'package:dimpos_store/features/product/repositories/cart_repository.dart';
import 'package:dimpos_store/features/product/ui/state/cart_state.dart';
import 'package:dimpos_store/features/product/ui/view_models/financial_shift_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/menu_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/promotion_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_view_model.g.dart';

@Riverpod(keepAlive: true)
class CartViewModel extends _$CartViewModel {
  @override
  FutureOr<CartState> build() async {
    return const CartState();
  }

  Future<void> initializeCart({
    required String brandId,
    required double taxRate,
  }) async {
    final carts = await ref.read(cartRepositoryProvider).getCarts();

    if (carts.isNullOrEmpty) {
      await ref.read(cartRepositoryProvider).addNewCart(
            brandId: brandId,
            taxRate: taxRate,
          );
      final carts = await ref.read(cartRepositoryProvider).getCarts();
      state = AsyncData(
        CartState(
          carts: carts!,
          selectedCartIndex: 0,
          isUpdatingCart: false,
        ),
      );
      ref.read(promotionViewModelProvider.notifier).getPromotionRules(
            cartId: carts[0].id,
          );
      ref.read(financialShiftViewModelProvider.notifier).getTakedTableNumber();
    } else {
      state = AsyncData(
        CartState(
          carts: carts!,
          selectedCartIndex: 0,
          isUpdatingCart: false,
        ),
      );
      ref.read(promotionViewModelProvider.notifier).getPromotionRules(
            cartId: carts[0].id,
          );
      ref.read(financialShiftViewModelProvider.notifier).getTakedTableNumber();
    }
  }

  Future<void> getCarts(int selectedIndex) async {
    if (state.value == null) return;
    state = AsyncData(
      state.value!.copyWith(
        isUpdatingCart: true,
      ),
    );
    final carts = await ref.read(cartRepositoryProvider).getCarts();
    if (carts.isNullOrEmpty) {
      return;
    }
    state = AsyncData(
      state.value!.copyWith(
        carts: carts,
        selectedCartIndex: selectedIndex,
        isUpdatingCart: false,
      ),
    );
    ref.read(promotionViewModelProvider.notifier).getPromotionRules(
          cartId: carts![selectedIndex].id,
        );
    ref.read(financialShiftViewModelProvider.notifier).getTakedTableNumber();
  }

  Future<void> createNewCart() async {
    if (state.value?.carts == null || state.value!.carts!.length >= 3) return;
    state = AsyncData(
      state.value!.copyWith(isUpdatingCart: true),
    );
    final menu = ref.read(menuViewModelProvider).value!.menu!;
    await ref.read(cartRepositoryProvider).addNewCart(
          brandId: menu.brandId,
          taxRate: menu.taxRate,
        );
    await getCarts(state.value!.carts!.length);
  }

  void setSelectedCart(int index) {
    final carts = state.value?.carts ?? [];
    if (state.value?.carts == null) return;
    if (index < 0 || index >= state.value!.carts!.length) return;
    state = AsyncData(
      state.value!.copyWith(carts: carts, selectedCartIndex: index),
    );
    ref.read(promotionViewModelProvider.notifier).getPromotionRules(
          cartId: carts[index].id,
        );
    ref.read(financialShiftViewModelProvider.notifier).getTakedTableNumber();
  }

  Future<void> applyPromotionToCart({
    required String cartId,
    required PromotionRule promotionRule,
  }) async {
    if (state.value?.carts?.isNullOrEmpty == true) return;
    state = AsyncData(
      state.value!.copyWith(isUpdatingCart: true),
    );
    CartAppliedPromotionDetail promotion = CartAppliedPromotionDetail(
      id: promotionRule.id,
      promotionRuleId: promotionRule.id,
      promotionNameSnapshot: promotionRule.name,
      discountValueCalculated: 0,
      actionType: promotionRule.ruleAction.actionType,
      actionValue: promotionRule.ruleAction.value,
      conditionRules: promotionRule.ruleConditions
          .map(
            (condition) => ConditionRule(
              conditionType: condition.conditionType,
              operator: condition.operator,
              conditionValue: condition.value,
            ),
          )
          .toList(),
      targetCriteriaForItemAction:
          promotionRule.ruleAction.targetCriteriaForItemAction,
      taxDiscountAmountForPercentage: 0,
      createdAt: DateTime.now(),
      ruleAction: promotionRule.ruleAction,
    );
    try {
      await ref
          .read(cartRepositoryProvider)
          .applyPromotionToCart(cartId: cartId, promotion: promotion);
      await getCarts(state.value!.selectedCartIndex);
    } catch (e) {
      rethrow;
    } finally {
      state = AsyncData(
        state.value!.copyWith(isUpdatingCart: false),
      );
    }
  }

  Future<void> removePromotionFromCart({
    required String cartId,
    required List<String> promotionIds,
  }) async {
    if (state.value?.carts?.isNullOrEmpty == true) return;
    state = AsyncData(
      state.value!.copyWith(isUpdatingCart: true),
    );
    try {
      await ref
          .read(cartRepositoryProvider)
          .removePromotionFromCart(cartId: cartId, promotionIds: promotionIds);
      await getCarts(state.value!.selectedCartIndex);
    } catch (e) {
      rethrow;
    } finally {
      state = AsyncData(
        state.value!.copyWith(isUpdatingCart: false),
      );
    }
  }

  Future<void> removeCart(int index) async {
    if (state.value?.carts == null || state.value!.carts!.length <= 1) return;
    state = AsyncData(
      state.value!.copyWith(isUpdatingCart: true),
    );
    var updatedSelectedIndex = state.value!.selectedCartIndex;
    final removeCartId = state.value!.carts![index].id;
    final currentLength = state.value!.carts!.length;
    // Tối đa có 3 giỏ hàng
    if (index == updatedSelectedIndex) {
      // If removing the currently selected cart
      if (index == currentLength - 1) {
        // If removing the last cart, select the previous one
        updatedSelectedIndex = index - 1;
      } else {
        // Otherwise, keep the same index (which will now point to the next cart)
        updatedSelectedIndex = index;
      }
    } else if (index < updatedSelectedIndex) {
      // Nếu đang xóa giỏ hàng trước giỏ hàng được chọn, không cần thay đổi chỉ số đã chọn
      updatedSelectedIndex--;
    } else {
      // Nếu đang xóa giỏ hàng sau giỏ hàng được chọn, không cần thay đổi chỉ số đã chọn
      updatedSelectedIndex = updatedSelectedIndex;
    }

    await ref.read(cartRepositoryProvider).removeCart(removeCartId);
    await getCarts(updatedSelectedIndex);
    setSelectedCart(updatedSelectedIndex);
  }

  Future<void> clearCart(int index) async {
    final stateValue = state.value;
    if (stateValue == null || stateValue.carts == null) return;
    final selectedCart = stateValue.carts![index];
    try {
      state = AsyncData(stateValue.copyWith(isUpdatingCart: true));
      for (var item in selectedCart.cartItems!) {
        await ref.read(cartRepositoryProvider).updateCartItem(
              cartId: selectedCart.id,
              cartItemId: item.id,
              quantity: 0,
            );
      }
      await removePromotionFromCart(
        cartId: selectedCart.id,
        promotionIds:
            selectedCart.promotionsApplied?.map((e) => e.id).toList() ?? [],
      );
      await getCarts(index);
    } catch (e) {
      rethrow;
    } finally {
      state = AsyncData(state.value!.copyWith(isUpdatingCart: false));
    }
  }

  Future<void> clearCartAfterOrder(int index) async {
    final stateValue = state.value;
    if (stateValue == null || stateValue.carts == null) return;
    final selectedCart = stateValue.carts![index];
    try {
      state = AsyncData(stateValue.copyWith(isUpdatingCart: true));
      for (var item in selectedCart.cartItems!) {
        await ref.read(cartRepositoryProvider).updateCartItem(
              cartId: selectedCart.id,
              cartItemId: item.id,
              quantity: 0,
            );
      }
      await removePromotionFromCart(
        cartId: selectedCart.id,
        promotionIds:
            selectedCart.promotionsApplied?.map((e) => e.id).toList() ?? [],
      );
      await ref.read(cartRepositoryProvider).updateCart(
            cartId: selectedCart.id,
            serviceMethod: ModeOfService.DineIn.index,
            takeNumberDineIn: 1,
          );
      await getCarts(index);
    } catch (e) {
      rethrow;
    } finally {
      state = AsyncData(state.value!.copyWith(isUpdatingCart: false));
    }
  }

  List<ModifierGroupItem> _extractModifierGroupItems(DetailProduct product) {
    final items = <ModifierGroupItem>[];

    if (product.modifierGroups.isNotNullOrEmpty) {
      for (var group in product.modifierGroups!) {
        final selectedOptions = group.modifierOptions
                ?.where((opt) => opt.isSelected == true)
                .toList() ??
            [];

        for (var option in selectedOptions) {
          items.add(ModifierGroupItem(
            modifierGroupId: group.id,
            modifierOptionId: option.id,
            modifierGroupNameSnapshot: group.name,
            modifierOptionSnapshot: option.name,
          ));
        }
      }
    }
    if (product.comboItems.isNotNullOrEmpty) {
      for (var comboItem in product.comboItems!) {
        for (var group in comboItem.modifierGroups ?? []) {
          final selectedOptions = group.modifierOptions
                  ?.where((opt) => opt.isSelected == true)
                  .toList() ??
              [];

          for (var option in selectedOptions) {
            items.add(ModifierGroupItem(
              modifierGroupId: group.id,
              modifierOptionId: option.id,
              modifierGroupNameSnapshot: group.name,
              modifierOptionSnapshot: option.name,
              relatedComboProductVariantItemId: comboItem.productVariant.id,
              relatedComboProductVariantItemName: comboItem.productVariant.name,
            ));
          }
        }
      }
    }

    return items;
  }

  List<ExtraProductItem>? _extractExtraProductItems(DetailProduct product) {
    final items = <ExtraProductItem>[];

    if (product.extraItemProductVariants.isNotNullOrEmpty) {
      for (var extraItem in product.extraItemProductVariants!) {
        if (extraItem.isSelected == true) {
          items.add(ExtraProductItem(
            extraProductVariantId: extraItem.id,
            extraProductVariantNameSnapshot: extraItem.name,
            unitPriceAtAdditionSnapshot: extraItem.price,
            quantity: extraItem.quantity,
            relatedProductVariantId: product.id,
          ));
        }
      }
    }

    return items.isNotEmpty ? items : null;
  }

  bool _areExtraItemsMatching(
    List<ExtraProductItem>? cartExtraItems,
    List<ExtraProductItem>? targetExtraItems,
  ) {
    if (cartExtraItems == null && targetExtraItems == null) return true;
    if (cartExtraItems == null || targetExtraItems == null) return false;
    if (cartExtraItems.length != targetExtraItems.length) return false;

    // Create sets of extra product IDs for comparison (ignore quantities)
    final cartExtraIds =
        cartExtraItems.map((item) => item.extraProductVariantId).toSet();

    final targetExtraIds =
        targetExtraItems.map((item) => item.extraProductVariantId).toSet();

    // Compare only the IDs, not the quantities
    return cartExtraIds.length == targetExtraIds.length &&
        cartExtraIds.containsAll(targetExtraIds);
  }

  List<ExtraProductItem>? _mergeExtraItems(
    List<ExtraProductItem>? existingExtraItems,
    List<ExtraProductItem>? newExtraItems,
  ) {
    if (newExtraItems == null || newExtraItems.isEmpty) {
      return existingExtraItems;
    }

    if (existingExtraItems == null || existingExtraItems.isEmpty) {
      return newExtraItems;
    }

    final mergedItems = <ExtraProductItem>[];
    final existingMap = <String, ExtraProductItem>{};

    // Map existing items by their ID
    for (var item in existingExtraItems) {
      existingMap[item.extraProductVariantId] = item;
    }

    // Merge with new items
    for (var newItem in newExtraItems) {
      final existingItem = existingMap[newItem.extraProductVariantId];
      if (existingItem != null) {
        // Update quantity of existing item
        mergedItems.add(existingItem.copyWith(
          quantity: existingItem.quantity + newItem.quantity,
        ));
        existingMap.remove(newItem.extraProductVariantId);
      } else {
        // Add new item
        mergedItems.add(newItem.copyWith(
          quantity: newItem.quantity,
        ));
      }
    }

    // Add remaining existing items that weren't updated
    mergedItems.addAll(existingMap.values);

    return mergedItems.isNotEmpty ? mergedItems : null;
  }

  List<(String, int)> _convertExtraItemsToTuples(
      List<ExtraProductItem>? extraItems) {
    if (extraItems == null || extraItems.isEmpty) return [];

    return extraItems
        .map((item) => (item.extraProductVariantId, item.quantity))
        .toList();
  }

  bool _validateExtraItemConsistency(
    List<ExtraProductItem>? extraItems,
    String relatedProductVariantId,
  ) {
    if (extraItems == null || extraItems.isEmpty) return true;

    return extraItems.every((item) =>
        item.relatedProductVariantId == relatedProductVariantId &&
        item.quantity > 0);
  }

  List<String> getExtraItemDescriptions(List<ExtraProductItem>? extraItems) {
    if (extraItems == null || extraItems.isEmpty) return [];

    return extraItems
        .map((item) =>
            '${item.extraProductVariantNameSnapshot} (${item.quantity}x)')
        .toList();
  }

  DetailProduct? reconstructDetailProductFromCartItem(CartItem cartItem) {
    final extraItemTuples = _convertExtraItemsToTuples(cartItem.extraItems);

    return ref.read(menuViewModelProvider.notifier).selectProductFromCartItem(
          productVariantId: cartItem.productVariantId,
          quantity: cartItem.quantity,
          totalPrice: cartItem.itemSubtotalAmount,
          modifierOptionIds: cartItem.modifierGroupItems
                  ?.map((modifier) => modifier.modifierOptionId)
                  .toList() ??
              [],
          extraProductItems: extraItemTuples,
          cartItemId: cartItem.id,
          notesForItem: cartItem.notesForItem,
          comboModifierOptionIds: cartItem.modifierGroupItems
              ?.where((modifier) =>
                  modifier.relatedComboProductVariantItemId != null)
              .map((modifier) => MapEntry(
                    modifier.relatedComboProductVariantItemId!,
                    modifier.modifierOptionId,
                  ))
              .fold<Map<String, List<String>>>({}, (map, entry) {
            map.putIfAbsent(entry.key, () => []).add(entry.value);
            return map;
          }),
        );
  }

  CartItem? _findMatchingCartItem({
    required List<CartItem> cartItems,
    required String productVariantId,
    required List<ModifierGroupItem> modifierGroupItems,
    required List<ExtraProductItem> extraProductItems,
  }) {
    final targetIds = modifierGroupItems.map((e) => e.modifierOptionId).toSet();

    return cartItems.firstWhereOrNull((item) {
      if (item.productVariantId != productVariantId) return false;

      final itemIds =
          item.modifierGroupItems?.map((e) => e.modifierOptionId).toSet() ?? {};

      // Check modifier group items match
      final modifiersMatch =
          itemIds.length == targetIds.length && itemIds.containsAll(targetIds);

      // Check extra items match
      final extraItemsMatch = _areExtraItemsMatching(
        item.extraItems,
        extraProductItems.isNotEmpty ? extraProductItems : null,
      );

      return modifiersMatch && extraItemsMatch;
    });
  }

  List<CartItem>? _findMatchingCartItems({
    required List<CartItem> cartItems,
    required String productVariantId,
    required List<ModifierGroupItem> modifierGroupItems,
    required List<ExtraProductItem> extraProductItems,
  }) {
    final targetIds = modifierGroupItems.map((e) => e.modifierOptionId).toSet();

    return cartItems.where((item) {
      if (item.productVariantId != productVariantId) return false;

      final itemIds =
          item.modifierGroupItems?.map((e) => e.modifierOptionId).toSet() ?? {};

      // Check modifier group items match
      final modifiersMatch =
          itemIds.length == targetIds.length && itemIds.containsAll(targetIds);

      // Check extra items match
      final extraItemsMatch = _areExtraItemsMatching(
        item.extraItems,
        extraProductItems.isNotEmpty ? extraProductItems : null,
      );

      return modifiersMatch && extraItemsMatch;
    }).toList();
  }

  Future<void> addItemToCart(DetailProduct product) async {
    if (state.value == null) return;

    state = AsyncData(state.value!.copyWith(isUpdatingCart: true));

    try {
      final productVariant = product.variants?.firstWhere(
        (variant) => variant.isSelected ?? false,
      );
      final productVariantId = productVariant?.id ?? product.id;
      final productVariantNameSnapshot = productVariant?.name ?? product.name;
      final unitPriceAtAdditionSnapshot =
          productVariant?.price ?? product.price;
      final quantity = product.quantity ?? 1;
      final productImageUrlSnapshot = product.imageUrl;
      final notesForItem = product.notesForItem;

      final modifierGroupItems = _extractModifierGroupItems(product);
      final extraItems = _extractExtraProductItems(product);

      // Validate extra item consistency
      if (extraItems != null &&
          !_validateExtraItemConsistency(extraItems, product.id)) {
        throw Exception('Invalid extra item configuration');
      }

      final currentCart = state.value!.carts![state.value!.selectedCartIndex];

      final existingItem = _findMatchingCartItem(
        cartItems: currentCart.cartItems ?? [],
        productVariantId: productVariantId,
        modifierGroupItems: modifierGroupItems,
        extraProductItems: extraItems ?? [],
      );

      if (existingItem != null) {
        // Update existing item - merge extra items properly
        final mergedExtraItems =
            _mergeExtraItems(existingItem.extraItems, extraItems);

        await ref.read(cartRepositoryProvider).updateCartItem(
              cartId: currentCart.id,
              cartItemId: existingItem.id,
              quantity: existingItem.quantity + quantity,
              modifierGroupItems: modifierGroupItems,
              extraProductItems: mergedExtraItems,
              notesForItem: notesForItem,
            );
      } else {
        // Add new item
        await ref.read(cartRepositoryProvider).addProductToCart(
              cartId: currentCart.id,
              productVariantId: productVariantId,
              productNameSnapshot: product.name,
              productVariantNameSnapshot: productVariantNameSnapshot,
              quantity: quantity,
              unitPriceAtAdditionSnapshot: unitPriceAtAdditionSnapshot,
              notesForItem: notesForItem,
              modifierGroupItems: modifierGroupItems,
              productImageUrlSnapshot: productImageUrlSnapshot,
              extraProductItems: extraItems,
            );
      }

      await getCarts(state.value!.selectedCartIndex);
    } catch (e) {
      rethrow;
    } finally {
      state = AsyncData(state.value!.copyWith(isUpdatingCart: false));
    }
  }

  Future<void> updateItemToCart(DetailProduct product) async {
    if (state.value == null) return;

    state = AsyncData(state.value!.copyWith(isUpdatingCart: true));

    try {
      final productVariant = product.variants?.firstWhere(
        (variant) => variant.isSelected ?? false,
      );
      final productVariantId = productVariant?.id ?? product.id;
      final quantity = product.quantity ?? 1;

      final modifierGroupItems = _extractModifierGroupItems(product);
      final extraItems = _extractExtraProductItems(product);

      // Validate extra item consistency
      if (extraItems != null &&
          !_validateExtraItemConsistency(extraItems, productVariantId)) {
        throw Exception('Invalid extra item configuration');
      }

      final currentCart = state.value!.carts![state.value!.selectedCartIndex];
      if (product.cartItemId != null) {
        final existingItems = _findMatchingCartItems(
          cartItems: currentCart.cartItems ?? [],
          productVariantId: productVariantId,
          modifierGroupItems: modifierGroupItems,
          extraProductItems: extraItems ?? [],
        );
        final existingItem = existingItems
            ?.firstWhereOrNull((item) => item.id != product.cartItemId);
        if (existingItem != null) {
          // Merge with existing item that has same configuration
          final mergedExtraItems = _mergeExtraItems(
            existingItem.extraItems,
            extraItems,
          );

          await ref.read(cartRepositoryProvider).updateCartItem(
                cartId: currentCart.id,
                cartItemId: existingItem.id,
                quantity: existingItem.quantity + quantity,
                modifierGroupItems: modifierGroupItems,
                extraProductItems: mergedExtraItems,
                notesForItem: product.notesForItem,
              );
          await ref.read(cartRepositoryProvider).updateCartItem(
                cartId: currentCart.id,
                cartItemId: product.cartItemId!,
                quantity: 0,
                modifierGroupItems: modifierGroupItems,
                extraProductItems: extraItems,
              );
        } else {
          // Update the current item directly
          await ref.read(cartRepositoryProvider).updateCartItem(
                cartId: currentCart.id,
                cartItemId: product.cartItemId!,
                quantity: quantity,
                modifierGroupItems: modifierGroupItems,
                extraProductItems: extraItems,
                notesForItem: product.notesForItem,
              );
        }
      }
      await getCarts(state.value!.selectedCartIndex);
    } catch (e) {
      rethrow;
    } finally {
      state = AsyncData(state.value!.copyWith(isUpdatingCart: false));
    }
  }

  Future<void> updateCartItemToCart({
    required String cartId,
    required String cartItemId,
    required int quantity,
    List<ModifierGroupItem> modifierGroupItems = const [],
    List<ExtraProductItem>? extraProductItems,
    String? notesForItem,
  }) async {
    if (quantity < 0) return;
    state = AsyncData(
      state.value!.copyWith(isUpdatingCart: true),
    );
    try {
      final currentCart = state.value!.carts![state.value!.selectedCartIndex];
      await ref.read(cartRepositoryProvider).updateCartItem(
            cartId: cartId,
            cartItemId: cartItemId,
            quantity: quantity,
            modifierGroupItems: modifierGroupItems,
            extraProductItems: extraProductItems,
            notesForItem: notesForItem,
          );
      // check if the cart is just one item
      if (quantity == 0 &&
          currentCart.cartItems != null &&
          currentCart.cartItems!.length == 1) {
        await removePromotionFromCart(
          cartId: currentCart.id,
          promotionIds:
              currentCart.promotionsApplied?.map((e) => e.id).toList() ?? [],
        );
      }
      await getCarts(state.value!.selectedCartIndex);
    } catch (e) {
      rethrow;
    } finally {
      state = AsyncData(
        state.value!.copyWith(isUpdatingCart: false),
      );
    }
  }

  Future<void> updateCart({
    required String cartId,
    int? serviceMethod,
    int? takeNumberDineIn,
  }) async {
    if (state.value?.carts == null) return;
    state = AsyncData(
      state.value!.copyWith(isUpdatingCart: true),
    );
    if (serviceMethod == null && takeNumberDineIn == null) {
      return;
    }

    if (serviceMethod == ModeOfService.DineIn.index) {
      await ref.read(cartRepositoryProvider).updateCart(
            cartId: cartId,
            serviceMethod: serviceMethod,
            takeNumberDineIn: takeNumberDineIn ?? 1,
          );
    } else if (serviceMethod == ModeOfService.TakeAway.index) {
      await ref.read(cartRepositoryProvider).updateCart(
            cartId: cartId,
            serviceMethod: serviceMethod,
            takeNumberDineIn: null,
          );
    }
    await getCarts(state.value!.selectedCartIndex);
  }

  Future<void> updateCartCustomerLoyaltyCardNumberSnapshot({
    required String cartId,
    required String customerLoyaltyCardNumberSnapshot,
  }) async {
    if (state.value?.carts == null) return;
    state = AsyncData(
      state.value!.copyWith(isUpdatingCart: true),
    );
    if (customerLoyaltyCardNumberSnapshot.isEmpty) {
      return;
    }

    await ref.read(cartRepositoryProvider).updateCart(
          cartId: cartId,
          customerLoyaltyCardNumberSnapshot: customerLoyaltyCardNumberSnapshot,
        );
    await getCarts(state.value!.selectedCartIndex);
  }

  bool isProductVariantExistInCart(int index, CartItem item) {
    // final stateValue = state.value;
    // if (stateValue == null) return false;
    // final carts = [...stateValue.carts];
    // final cart = carts[index];
    // var cartItems = cart.cartItems;
    // var existCartItems = cartItems!.where((element) {
    //   return ((element.productVariantId == item.productVariantId) &&
    //       (element.selectedOptions.toString() ==
    //           item.selectedOptions.toString()));
    // });
    // if (existCartItems.isNullOrEmpty) return false;
    return true;
  }

  void setDraftOrder(Cart? cart, int? draftCartIndex) {
    if (state.value == null) {
      return;
    }
    state = AsyncData(
      state.value!.copyWith(
        draftOrder: cart,
        draftCartIndex: draftCartIndex ?? 0,
      ),
    );
  }

  void setDraftOrderCode(String draftOrderCode) {
    if (state.value == null || state.value!.draftOrder == null) {
      return;
    }
    final draftOrder = state.value!.draftOrder!;

    state = AsyncData(
      state.value!.copyWith(
        draftOrder: draftOrder.copyWith(draftOrderCode: draftOrderCode),
      ),
    );
  }
}
