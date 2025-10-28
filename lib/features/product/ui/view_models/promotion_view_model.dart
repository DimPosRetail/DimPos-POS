import 'package:dimpos_store/extensions/iterable_extension.dart';
import 'package:dimpos_store/features/product/repositories/promotion_rule_repository.dart';
import 'package:dimpos_store/features/product/ui/state/promotion_state.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'promotion_view_model.g.dart';

@Riverpod(keepAlive: true)
class PromotionViewModel extends _$PromotionViewModel {
  @override
  FutureOr<PromotionState> build() async {
    return PromotionState(promotionRules: null);
  }

  Future<void> getPromotionRules({
    required String cartId,
  }) async {
    // if (state.value == null) return;
    // state = const AsyncLoading();
    final currentCart = ref
        .read(cartViewModelProvider)
        .value
        ?.carts
        .firstWhereOrNull((e) => e.id == cartId);
    state = AsyncData(
      state.value?.copyWith(
            isLoading: true,
          ) ??
          PromotionState(
            promotionRules: null,
            isLoading: true,
          ),
    );
    final promotionRules = await ref
        .read(promotionRuleRepositoryProvider)
        .getPromotionRules(cartId: cartId);
    if (promotionRules.isNullOrEmpty) {
      state = AsyncData(
        PromotionState(
          promotionRules: [],
          isLoading: false,
        ),
      );
      return;
    }
    final isWarning = currentCart?.promotionsApplied?.any((e) =>
            promotionRules
                ?.any((p) => p.id == e.promotionRuleId && !p.isValid) ??
            false) ??
        false;
    state = AsyncData(
      PromotionState(
        promotionRules: promotionRules!,
        isWarning: isWarning,
      ),
    );
  }

  void selectPromotionRules(String id) {
    if (state.value?.promotionRules?.isNullOrEmpty == true) {
      return;
    }
    final promotionRules = state.value?.promotionRules;
    if (promotionRules.isNotNullOrEmpty) {
      // choose only one promotion rule
      final currentSelectedPromotionRules = promotionRules!
          .map((e) => e.copyWith(isSelected: e.id == id))
          .toList();
      // providerLogger.d(
      //   'Selected promotion rule: $currentSelectedPromotionRules',
      // );
      state = AsyncData(
        PromotionState(promotionRules: currentSelectedPromotionRules),
      );
    }
  }
}
