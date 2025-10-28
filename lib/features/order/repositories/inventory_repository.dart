import 'package:dimpos_store/enums/api_url.dart';
import 'package:dimpos_store/utils/request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_repository.g.dart';

@riverpod
InventoryRepository inventoryRepository(Ref ref) {
  return const InventoryRepository();
}

class InventoryRepository {
  const InventoryRepository();

  Future<void> rollBackInventoryManually(String orderId) async {
    await apiClient
        .getClient(ApiUrl.inventory)
        .patch('/inventory-stocks/orders/$orderId/rollback');
  }
}
