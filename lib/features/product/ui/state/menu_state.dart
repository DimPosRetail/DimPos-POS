import 'package:dimpos_store/features/product/models/category.dart';
import 'package:dimpos_store/features/product/models/detail_product.dart';
import 'package:dimpos_store/features/product/models/menu.dart';
import 'package:dimpos_store/features/product/models/modifier_group.dart';
import 'package:dimpos_store/features/product/models/product.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_state.freezed.dart';
part 'menu_state.g.dart';

@freezed
class MenuState with _$MenuState {
  const factory MenuState({
    Menu? menu,
    @Default(1) int selectedCategoryIndex,
    @Default([]) List<Product> allProductsList,
    @Default([]) List<Product> productsListWithCategory,
    @Default([]) List<Category> childCategories,
    @Default([]) List<ModifierGroup> modifierGroupWithProduct,
    DetailProduct? selectedProduct,
    @Default([]) List<String> selectedChildCategories,
    @Default('') String searchQuery,
    // @Default(null) List<String> selectedModi
  }) = _MenuState;

  factory MenuState.fromJson(Map<String, dynamic> json) =>
      _$MenuStateFromJson(json);
}
