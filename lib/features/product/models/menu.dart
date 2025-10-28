import 'package:dimpos_store/features/product/models/category.dart';
import 'package:dimpos_store/features/product/models/modifier_group.dart';
import 'package:dimpos_store/features/product/models/product.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu.freezed.dart';
part 'menu.g.dart';

@freezed
class Menu with _$Menu {
  const factory Menu({
    required String brandId,
    required double taxRate,
    @Default([]) List<Category>? categories,
    @Default([]) List<Product>? products,
    @Default([]) List<ModifierGroup> modifierGroups,
  }) = _Menu;
  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);
}
