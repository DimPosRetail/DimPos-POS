import 'package:dimpos_store/enums/api_url.dart';
import 'package:dimpos_store/features/common/models/base_response.dart';
import 'package:dimpos_store/features/product/models/menu.dart';
import 'package:dimpos_store/utils/request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'menu_repository.g.dart';

@riverpod
MenuRepository menuRepository(Ref ref) {
  return const MenuRepository();
}

class MenuRepository {
  const MenuRepository();

  Future<Menu?> getCategories() async {
    try {
      final response = await apiClient.getClient(ApiUrl.menu).get(
            '/store-menus/pos',
          );

      final menu = BaseResponse<Menu>.fromJson(response.data,
          (json) => Menu.fromJson(json as Map<String, dynamic>)).data;
      return menu;
    } catch (e) {
      rethrow;
    }
  }
}
