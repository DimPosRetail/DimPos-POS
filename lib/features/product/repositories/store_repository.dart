import 'package:dimpos_store/enums/api_url.dart';
import 'package:dimpos_store/features/common/models/base_response.dart';
import 'package:dimpos_store/features/product/models/store.dart';
import 'package:dimpos_store/utils/request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'store_repository.g.dart';

@riverpod
StoreRepository storeRepository(Ref ref) {
  return const StoreRepository();
}

class StoreRepository {
  const StoreRepository();

  Future<Store?> getStoreDetails() async {
    final response = await apiClient.getClient(ApiUrl.store).get(
          '/stores/detail',
        );
    final store = BaseResponse<Store?>.fromJson(
      response.data,
      (json) => Store.fromJson(json as Map<String, dynamic>),
    ).data;
    return store;
  }
}
