import 'dart:async';

import 'package:dimpos_store/features/product/models/store.dart';
import 'package:dimpos_store/features/product/repositories/store_repository.dart';
import 'package:dimpos_store/features/product/ui/state/store_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'store_view_model.g.dart';

@Riverpod(keepAlive: true)
class StoreViewModel extends _$StoreViewModel {
  @override
  FutureOr<StoreState> build() {
    return const StoreState();
  }

  Future<Store?> getStoreInfo() async {
    state = const AsyncLoading();
    final response = await ref.read(storeRepositoryProvider).getStoreDetails();
    // state = AsyncValue.data(store);
    state = AsyncData(StoreState(storeInfo: response));
    return response;
  }
}
