import 'package:dimpos_store/features/order/ui/view_models/order_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/financial_shift_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/menu_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/store_view_model.dart';
import 'package:dimpos_store/utils/exception.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'init_app.g.dart';

@Riverpod(keepAlive: true)
class InitApp extends _$InitApp {
  @override
  FutureOr<void> build() async {
    // This is where you can initialize any app-wide settings or configurations.
    // For example, you might want to set up logging, initialize services, etc.
    // Currently, this method does nothing but can be extended in the future.
  }

  Future<void> init() async {
    state = const AsyncLoading();
    try {
      await ref
          .read(financialShiftViewModelProvider.notifier)
          .checkFinancialShiftOpen();
      await ref.read(menuViewModelProvider.notifier).getMenu();
      final store =
          await ref.read(storeViewModelProvider.notifier).getStoreInfo();
      if (store == null) {
        return;
      }
      ref.read(cartViewModelProvider.notifier).initializeCart(
            brandId: store.brandId,
            taxRate: store.taxRate?.rate ?? 0.0,
          );
    } catch (e) {
      handleApiError(error: e as DioException);
    } finally {
      state = const AsyncData(null);
    }
  }

  Future<void> dispose() async {
    // Reset the state of the app if needed
    ref.invalidate(menuViewModelProvider);
    ref.invalidate(cartViewModelProvider);
    ref.invalidate(orderViewModelProvider);
    ref.invalidate(financialShiftViewModelProvider);
  }
}
