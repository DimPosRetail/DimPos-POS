import 'package:dimpos_store/enums/modifier_group_selected_type.dart';
import 'package:dimpos_store/features/product/models/category.dart';
import 'package:dimpos_store/features/product/models/combo_item.dart';
import 'package:dimpos_store/features/product/models/detail_product.dart';
import 'package:dimpos_store/features/product/models/extra_item.dart';
import 'package:dimpos_store/features/product/models/menu.dart';
import 'package:dimpos_store/features/product/models/modifier_group.dart';
import 'package:dimpos_store/features/product/models/product.dart';
import 'package:dimpos_store/features/product/repositories/menu_repository.dart';
import 'package:dimpos_store/features/product/ui/state/menu_state.dart';
import 'package:dimpos_store/utils/logger_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'menu_view_model.g.dart';

@Riverpod(keepAlive: true)
class MenuViewModel extends _$MenuViewModel {
  @override
  FutureOr<MenuState> build() async {
    return const MenuState();
  }

  Future<Menu?> getMenu() async {
    try {
      state = const AsyncLoading();
      final menu = await ref.read(menuRepositoryProvider).getCategories();
      if (menu == null) {
        state = AsyncData(const MenuState());
        return null;
      }
      providerLogger.d('Menu loaded: $menu');
      state = AsyncData(
        MenuState(
          menu: menu,
          selectedCategoryIndex: 0,
          allProductsList: menu.products ?? [],
          productsListWithCategory: menu.products ?? [],
          childCategories: [],
          modifierGroupWithProduct: menu.modifierGroups,
          selectedChildCategories: [],
        ),
      );
      return menu;
    } catch (e) {
      rethrow;
    }
  }

  void setSelectedCategoryIndex(int index) {
    if (state.value == null) {
      return;
    }
    final products = state.value?.menu?.products ?? [];
    final categories = state.value?.menu?.categories
            ?.where(
              (category) => products.any((product) =>
                  product.categoryId == category.id ||
                  category.childCategories?.any((childCategory) =>
                          childCategory.id == product.categoryId) ==
                      true),
            )
            .toList() ??
        [];

    // Get child categories for the selected category
    List<Category> childCategories = [];
    if (index > 0 && index - 1 < categories.length) {
      childCategories = categories[index - 1].childCategories ?? [];
    }

    state = AsyncData(
      state.value!.copyWith(
        selectedCategoryIndex: index,
        childCategories: childCategories,
        selectedChildCategories: childCategories
            .map((child) => child.id)
            .toList(), // Reset child category selection
        searchQuery: '', // Reset search when changing category
      ),
    );

    // Apply filters to update the products list
    _applyFilters();

    providerLogger.d(
      'Child categories for selected category index $index: ${state.value?.childCategories}',
    );
  }

  void toggleChildCategory(String categoryId) {
    if (state.value == null) {
      return;
    }
    final currentSelected = state.value!.selectedChildCategories;
    List<String> newSelected;
    if (currentSelected.contains(categoryId)) {
      newSelected = currentSelected.where((id) => id != categoryId).toList();
    } else {
      newSelected = [...currentSelected, categoryId];
    }
    state = AsyncData(
      state.value!.copyWith(
        selectedChildCategories: newSelected,
      ),
    );
  }

  void applyChildCategoryFilter() {
    _applyFilters();
  }

  void setSearchQuery(String query) {
    if (state.value == null) {
      return;
    }
    state = AsyncData(
      state.value!.copyWith(
        searchQuery: query,
      ),
    );
    _applyFilters();
  }

  void _applyFilters() {
    if (state.value == null) {
      return;
    }

    final searchQuery = state.value!.searchQuery.toLowerCase().trim();
    final selectedChildCategories = state.value!.selectedChildCategories;

    // Start with all products or category-specific products
    List<Product> baseProducts;
    if (state.value!.selectedCategoryIndex == 0) {
      baseProducts = List<Product>.from(state.value!.allProductsList);
    } else {
      final products = state.value?.menu?.products ?? [];
      final categories = state.value?.menu?.categories
              ?.where(
                (category) => products.any((product) =>
                    product.categoryId == category.id ||
                    category.childCategories?.any((childCategory) =>
                            childCategory.id == product.categoryId) ==
                        true),
              )
              .toList() ??
          [];
      if (state.value!.selectedCategoryIndex - 1 < categories.length) {
        final selectedCategory =
            categories[state.value!.selectedCategoryIndex - 1];
        baseProducts = state.value!.allProductsList
            .where((product) =>
                product.categoryId == selectedCategory.id ||
                (selectedChildCategories.isNotEmpty &&
                    selectedChildCategories.contains(product.categoryId)))
            .toList();
      } else {
        baseProducts = [];
      }
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      baseProducts = baseProducts.where((product) {
        final name = product.name.toLowerCase();
        final description = product.description.toLowerCase();
        return name.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    }

    // Apply child category filter
    // if (selectedChildCategories.isNotEmpty) {
    //   baseProducts = baseProducts
    //       .where(
    //           (product) => selectedChildCategories.contains(product.categoryId))
    //       .toList();
    // }

    state = AsyncData(
      state.value!.copyWith(
        productsListWithCategory: baseProducts,
      ),
    );
  }

  void filterByChildCategory(List<String> childCategoryIds) {
    if (state.value == null) {
      return;
    }
    final products = state.value!.menu?.products ?? [];
    final filteredProducts = products
        .where((product) => childCategoryIds.contains(product.categoryId))
        .toList();
    state = AsyncData(
      state.value!.copyWith(
        productsListWithCategory: filteredProducts,
      ),
    );
  }

  DetailProduct? selectProduct(String productId) {
    if (state.value == null) {
      return null;
    }
    final selectedProduct = state.value!.productsListWithCategory
        .firstWhere((product) => product.id == productId);
    providerLogger.d('Selected product: $selectedProduct');
    var detailProduct = DetailProduct(
      id: selectedProduct.id,
      name: selectedProduct.name,
      description: selectedProduct.description,
      price: selectedProduct.price,
      imageUrl: selectedProduct.imageUrl,
    );
    final productVariants = state.value!.productsListWithCategory
        .firstWhere((product) => product.id == productId)
        .productVariants;
    final comboItems = state.value!.productsListWithCategory
        .firstWhere((product) => product.id == productId)
        .comboItems;
    final extraItems = state.value!.productsListWithCategory
        .firstWhere((product) => product.id == productId)
        .extraItemProductVariants;
    if (extraItems != null && extraItems.isNotEmpty) {
      detailProduct = detailProduct.copyWith(
        extraItemProductVariants: extraItems,
      );
    }
    if (productVariants != null && productVariants.isNotEmpty) {
      final updatedProductVariants = productVariants.map((variant) {
        return variant.copyWith(isSelected: false);
      }).toList();
      if (updatedProductVariants.isNotEmpty) {
        updatedProductVariants[0] = updatedProductVariants[0].copyWith(
          isSelected: true,
        );
      }
      detailProduct = detailProduct.copyWith(
        variants: updatedProductVariants,
      );
      final selectedProductVariantId = detailProduct.variants!
          .firstWhere(
            (variant) => variant.isSelected == true,
          )
          .id;
      final modifierGroups = state.value!.modifierGroupWithProduct
          .where((group) =>
              group.productVariantIds.contains(selectedProductVariantId))
          .toList();
      List<ModifierGroup> updatedModifierGroups = [];
      if (modifierGroups.isNotEmpty) {
        for (var i = 0; i < modifierGroups.length; i++) {
          var group = modifierGroups[i];
          if (group.modifierOptions != null &&
              group.modifierOptions!.isNotEmpty) {
            final updatedOptions = group.modifierOptions!.map((option) {
              return option.copyWith(isSelected: false);
            }).toList();
            // if (updatedOptions.isNotEmpty) {
            //   updatedOptions[0] = updatedOptions[0].copyWith(
            //     isSelected: true,
            //   );
            // }
            group = group.copyWith(
              modifierOptions: updatedOptions,
            );
          }
          updatedModifierGroups.add(group);
        }
      }
      detailProduct = detailProduct.copyWith(
        modifierGroups:
            updatedModifierGroups.isNotEmpty ? updatedModifierGroups : null,
        totalPrice: updatedProductVariants[0].price,
        quantity: 1,
        notesForItem: "",
      );
    } else if (comboItems != null && comboItems.isNotEmpty) {
      final productVariantIdsInCombo =
          comboItems.map((comboItem) => comboItem.productVariant.id).toList();
      final modifierGroups = state.value!.modifierGroupWithProduct
          .where((group) => group.productVariantIds
              .any((variantId) => productVariantIdsInCombo.contains(variantId)))
          .toList();
      List<ComboItem> updatedComboItems = [];
      for (var comboItem in comboItems) {
        updatedComboItems.add(
          comboItem.copyWith(
            productVariant: comboItem.productVariant.copyWith(
              isSelected: false,
            ),
            modifierGroups: modifierGroups
                .where((group) => group.productVariantIds
                    .contains(comboItem.productVariant.id))
                .toList(),
          ),
        );
      }
      detailProduct = detailProduct.copyWith(
        comboItems: updatedComboItems,
        totalPrice: detailProduct.price,
        quantity: 1,
        notesForItem: "",
      );
    } else {
      final modifierGroups = state.value!.modifierGroupWithProduct
          .where((group) => group.productVariantIds.contains(productId))
          .toList();
      List<ModifierGroup> updatedModifierGroups = [];
      if (modifierGroups.isNotEmpty) {
        for (var i = 0; i < modifierGroups.length; i++) {
          var group = modifierGroups[i];
          if (group.modifierOptions != null &&
              group.modifierOptions!.isNotEmpty) {
            final updatedOptions = group.modifierOptions!.map((option) {
              return option.copyWith(isSelected: false);
            }).toList();
            // if (updatedOptions.isNotEmpty) {
            //   updatedOptions[0] = updatedOptions[0].copyWith(
            //     isSelected: true,
            //   );
            // }
            group = group.copyWith(
              modifierOptions: updatedOptions,
            );
          }
          updatedModifierGroups.add(group);
        }
      }
      detailProduct = detailProduct.copyWith(
        modifierGroups:
            updatedModifierGroups.isNotEmpty ? updatedModifierGroups : null,
        totalPrice: detailProduct.price,
        quantity: 1,
        notesForItem: "",
      );
    }

    state = AsyncData(
      state.value!.copyWith(
        selectedProduct: detailProduct,
      ),
    );
    providerLogger.d('Product selected: $detailProduct');
    return detailProduct;
  }

  DetailProduct? selectProductFromCartItem({
    required String productVariantId,
    required int quantity,
    required double totalPrice,
    required List<String> modifierOptionIds,
    required List<(String, int)> extraProductItems,
    required String cartItemId,
    String? notesForItem,
    Map<String, List<String>>?
        comboModifierOptionIds, // New parameter for combo modifiers
  }) {
    if (state.value == null) {
      return null;
    }

    final productId = _getProductIdFromCartItem(productVariantId);
    if (productId == null) {
      return null;
    }

    final originalProduct = state.value!.productsListWithCategory
        .firstWhere((product) => product.id == productId);

    var detailProduct = DetailProduct(
      id: originalProduct.id,
      name: originalProduct.name,
      description: originalProduct.description,
      price: originalProduct.price,
      imageUrl: originalProduct.imageUrl,
      extraItemProductVariants: originalProduct.extraItemProductVariants,
    );

    final productVariants = originalProduct.productVariants;
    final comboItems = originalProduct.comboItems;
    final extraItems = originalProduct.extraItemProductVariants;

    if (extraItems != null && extraItems.isNotEmpty) {
      List<ExtraItem> updatedExtraItems = extraItems.map((extra) {
        final matchingItems =
            extraProductItems.where((item) => item.$1 == extra.id).toList();
        final matchingItem =
            matchingItems.isNotEmpty ? matchingItems.first : null;

        return extra.copyWith(
          isSelected: matchingItem != null && matchingItem.$2 > 0,
          quantity: matchingItem?.$2 ??
              extra.quantity, // Preserve original quantity if not found
        );
      }).toList();

      detailProduct = detailProduct.copyWith(
        extraItemProductVariants: updatedExtraItems,
      );
    }

    // Handle products with variants
    if (productVariants != null && productVariants.isNotEmpty) {
      final updatedProductVariants = productVariants.map((variant) {
        return variant.copyWith(isSelected: variant.id == productVariantId);
      }).toList();

      detailProduct = detailProduct.copyWith(variants: updatedProductVariants);

      final selectedProductVariantId = detailProduct.variants!
          .firstWhere((variant) => variant.isSelected == true)
          .id;

      final modifierGroups = state.value!.modifierGroupWithProduct
          .where((group) =>
              group.productVariantIds.contains(selectedProductVariantId))
          .toList();

      List<ModifierGroup> updatedModifierGroups = [];
      if (modifierGroups.isNotEmpty) {
        for (var group in modifierGroups) {
          if (group.modifierOptions != null &&
              group.modifierOptions!.isNotEmpty) {
            final updatedOptions = group.modifierOptions!.map((option) {
              return option.copyWith(
                  isSelected: modifierOptionIds.contains(option.id));
            }).toList();
            updatedModifierGroups
                .add(group.copyWith(modifierOptions: updatedOptions));
          }
        }
      }

      detailProduct = detailProduct.copyWith(
        modifierGroups:
            updatedModifierGroups.isNotEmpty ? updatedModifierGroups : null,
        totalPrice: totalPrice,
        quantity: quantity,
        notesForItem: notesForItem ?? "",
      );
    } else if (comboItems != null && comboItems.isNotEmpty) {
      final productVariantIdsInCombo =
          comboItems.map((comboItem) => comboItem.productVariant.id).toList();

      final modifierGroups = state.value!.modifierGroupWithProduct
          .where((group) => group.productVariantIds
              .any((variantId) => productVariantIdsInCombo.contains(variantId)))
          .toList();

      List<ComboItem> updatedComboItems = [];
      for (var comboItem in comboItems) {
        // Get modifier groups for this combo item
        final comboItemModifierGroups = modifierGroups
            .where((group) =>
                group.productVariantIds.contains(comboItem.productVariant.id))
            .toList();

        // Update modifier groups with selected options from cart
        List<ModifierGroup> updatedComboModifierGroups = [];
        for (var group in comboItemModifierGroups) {
          if (group.modifierOptions != null &&
              group.modifierOptions!.isNotEmpty) {
            // FIXED: Use productVariant.id as key instead of comboItem.id
            final comboItemSelectedOptions =
                comboModifierOptionIds?[comboItem.productVariant.id] ?? [];

            final updatedOptions = group.modifierOptions!.map((option) {
              return option.copyWith(
                  isSelected: comboItemSelectedOptions.contains(option.id));
            }).toList();

            updatedComboModifierGroups
                .add(group.copyWith(modifierOptions: updatedOptions));
          }
        }

        updatedComboItems.add(
          comboItem.copyWith(
            productVariant: comboItem.productVariant.copyWith(
              isSelected: comboItem.productVariant.id == productVariantId,
            ),
            modifierGroups: updatedComboModifierGroups.isNotEmpty
                ? updatedComboModifierGroups
                : null,
          ),
        );
      }

      detailProduct = detailProduct.copyWith(
        comboItems: updatedComboItems,
        totalPrice: totalPrice,
        quantity: quantity,
        notesForItem: notesForItem ?? "",
      );
    }
    // Handle regular products (no variants, no combo)
    else {
      final modifierGroups = state.value!.modifierGroupWithProduct
          .where((group) => group.productVariantIds.contains(productId))
          .toList();

      List<ModifierGroup> updatedModifierGroups = [];
      if (modifierGroups.isNotEmpty) {
        for (var group in modifierGroups) {
          if (group.modifierOptions != null &&
              group.modifierOptions!.isNotEmpty) {
            final updatedOptions = group.modifierOptions!.map((option) {
              return option.copyWith(
                  isSelected: modifierOptionIds.contains(option.id));
            }).toList();
            updatedModifierGroups
                .add(group.copyWith(modifierOptions: updatedOptions));
          }
        }
      }

      detailProduct = detailProduct.copyWith(
        modifierGroups:
            updatedModifierGroups.isNotEmpty ? updatedModifierGroups : null,
        totalPrice: totalPrice,
        quantity: quantity,
        notesForItem: notesForItem ?? "",
      );
    }

    // Update state with the reconstructed product
    state = AsyncData(
      state.value!.copyWith(
        selectedProduct: detailProduct.copyWith(
          isUpdated: true,
          cartItemId: cartItemId,
        ),
      ),
    );

    providerLogger.d('Product selected from cart item: $detailProduct');
    return detailProduct;
  }

// Helper method to get product ID from cart item (enhanced)
  String? _getProductIdFromCartItem(String productVariantId) {
    if (state.value == null || state.value!.productsListWithCategory.isEmpty) {
      return null;
    }

    try {
      final product = state.value!.allProductsList.firstWhere(
        (product) =>
            // Direct product match
            (product.id == productVariantId) ||
            // Product variant match
            (product.productVariants
                    ?.any((variant) => variant.id == productVariantId) ==
                true) ||
            // Combo item product variant match
            (product.comboItems?.any((comboItem) =>
                    comboItem.productVariant.id == productVariantId) ==
                true),
      );
      return product.id;
    } catch (e) {
      providerLogger.e('Product not found for variant ID: $productVariantId');
      return null;
    }
  }

  void selectVariant(String variantId) {
    if (state.value == null || state.value!.selectedProduct == null) {
      return;
    }
    DetailProduct selectedProduct = state.value!.selectedProduct!;
    if (selectedProduct.variants != null) {
      final updatedVariants = selectedProduct.variants!.map((variant) {
        return variant.copyWith(
          isSelected: variant.id == variantId,
        );
      }).toList();

      selectedProduct = selectedProduct.copyWith(
        variants: updatedVariants,
      );

      double newTotalPrice = _calculateTotalPrice(
          selectedProduct, selectedProduct.modifierGroups, null);

      state = AsyncData(
        state.value!.copyWith(
          selectedProduct: selectedProduct.copyWith(
            totalPrice: newTotalPrice,
          ),
        ),
      );
    }
  }

  void selectExtraItem(String extraProductItemId) {
    if (state.value == null || state.value!.selectedProduct == null) {
      return;
    }
    DetailProduct selectedProduct = state.value!.selectedProduct!;
    if (selectedProduct.extraItemProductVariants != null) {
      final updatedExtraItems =
          selectedProduct.extraItemProductVariants!.map((extraItem) {
        return extraItem.copyWith(
          isSelected: extraItem.id == extraProductItemId
              ? !extraItem.isSelected
              : extraItem.isSelected,
        );
      }).toList();

      selectedProduct = selectedProduct.copyWith(
        extraItemProductVariants: updatedExtraItems,
      );

      double newTotalPrice = _calculateTotalPrice(
          selectedProduct, selectedProduct.modifierGroups, updatedExtraItems);

      state = AsyncData(
        state.value!.copyWith(
          selectedProduct: selectedProduct.copyWith(
            totalPrice: newTotalPrice,
          ),
        ),
      );
    }
  }

  void selectModifierOption({
    required String modifierGroupId,
    required String modifierOptionId,
  }) {
    if (state.value == null || state.value!.selectedProduct == null) {
      return;
    }
    DetailProduct selectedProduct = state.value!.selectedProduct!;

    final updatedModifierGroups = selectedProduct.modifierGroups?.map((group) {
      if (group.id == modifierGroupId) {
        var updatedOptions =
            group.selectedType == ModifierGroupSelectedType.Single.index
                ? group.modifierOptions?.map((option) {
                    return option.copyWith(
                      isSelected: option.id == modifierOptionId
                          ? !option.isSelected
                          : false,
                    );
                  }).toList()
                : group.modifierOptions?.map((option) {
                    return option.copyWith(
                      isSelected: option.id == modifierOptionId
                          ? !option.isSelected
                          : option.isSelected,
                    );
                  }).toList();
        return group.copyWith(modifierOptions: updatedOptions);
      }
      return group;
    }).toList();
    double newTotalPrice =
        _calculateTotalPrice(selectedProduct, updatedModifierGroups, null);

    state = AsyncData(
      state.value!.copyWith(
        selectedProduct: selectedProduct.copyWith(
          modifierGroups: updatedModifierGroups,
          totalPrice: newTotalPrice,
        ),
      ),
    );
  }

  void selectComboModifierOption({
    required String productVariantId, // Changed from comboItemId
    required String modifierGroupId,
    required String modifierOptionId,
  }) {
    if (state.value == null || state.value!.selectedProduct == null) {
      return;
    }

    DetailProduct selectedProduct = state.value!.selectedProduct!;

    if (selectedProduct.comboItems == null ||
        selectedProduct.comboItems!.isEmpty) {
      return;
    }

    // Update combo items with modified modifier groups
    final updatedComboItems = selectedProduct.comboItems!.map((comboItem) {
      // FIXED: Match by productVariant.id instead of comboItem.id
      if (comboItem.productVariant.id == productVariantId) {
        // Found the target combo item, update its modifier groups
        final updatedModifierGroups = comboItem.modifierGroups?.map((group) {
          if (group.id == modifierGroupId) {
            // Found the target modifier group, update its options
            var updatedOptions =
                group.selectedType == ModifierGroupSelectedType.Single.index
                    ? group.modifierOptions?.map((option) {
                        // For single selection: unselect all others, toggle the selected one
                        return option.copyWith(
                          isSelected: option.id == modifierOptionId
                              ? !(option.isSelected)
                              : false,
                        );
                      }).toList()
                    : group.modifierOptions?.map((option) {
                        // For multiple selection: only toggle the selected option
                        return option.copyWith(
                          isSelected: option.id == modifierOptionId
                              ? !(option.isSelected)
                              : (option.isSelected),
                        );
                      }).toList();

            return group.copyWith(modifierOptions: updatedOptions);
          }
          return group;
        }).toList();

        return comboItem.copyWith(modifierGroups: updatedModifierGroups);
      }
      return comboItem;
    }).toList();

    // Calculate new total price including combo modifiers
    double newTotalPrice = _calculateTotalPriceWithCombo(
      selectedProduct.copyWith(comboItems: updatedComboItems),
    );

    // Update the state
    state = AsyncData(
      state.value!.copyWith(
        selectedProduct: selectedProduct.copyWith(
          comboItems: updatedComboItems,
          totalPrice: newTotalPrice,
        ),
      ),
    );

    providerLogger.d(
        'Combo modifier option selected: productVariantId=$productVariantId, groupId=$modifierGroupId, optionId=$modifierOptionId');
  }

  double _calculateTotalPriceWithCombo(DetailProduct product) {
    double basePrice = product.price;

    final quantity = product.quantity ?? 1;
    return (basePrice) * quantity;
  }

  double _calculateTotalPrice(DetailProduct product,
      List<ModifierGroup>? modifierGroups, List<ExtraItem>? extraItems) {
    // Base price (variant price or product price)
    double basePrice = 0.0;

    if (product.variants != null && product.variants!.isNotEmpty) {
      final selectedVariant = product.variants!.firstWhere(
        (variant) => variant.isSelected == true,
        orElse: () => product.variants!.first,
      );
      basePrice = selectedVariant.price;
    } else {
      basePrice = product.price;
    }
    basePrice = basePrice * (product.quantity ?? 1);
    if (extraItems != null && extraItems.isNotEmpty) {
      double extraItemsPrice = 0.0;
      for (var extraItem in extraItems) {
        if (extraItem.isSelected == true) {
          extraItemsPrice += (extraItem.price * extraItem.quantity);
        }
      }
      basePrice += extraItemsPrice;
      providerLogger.d('Extra items price added: $extraItemsPrice');
    }
    return basePrice;
  }

  void resetProductSelection() {
    if (state.value == null) {
      return;
    }
    final currentState = state.value!;
    state = AsyncData(
      currentState.copyWith(
        selectedProduct: null,
      ),
    );
    providerLogger.d('Product selection reset');
  }

  void decreaseQuantity() {
    if (state.value == null || state.value!.selectedProduct == null) {
      return;
    }
    final selectedProduct = state.value!.selectedProduct!;
    if (selectedProduct.quantity! > 1) {
      final calculatingProduct = selectedProduct.copyWith(
        quantity: selectedProduct.quantity! - 1,
      );
      final newTotalPrice = _calculateTotalPrice(
        calculatingProduct,
        calculatingProduct.modifierGroups,
        calculatingProduct.extraItemProductVariants,
      );
      final updatedProduct = selectedProduct.copyWith(
        quantity: calculatingProduct.quantity!,
        totalPrice: newTotalPrice,
      );
      state = AsyncData(
        state.value!.copyWith(
          selectedProduct: updatedProduct,
        ),
      );
      providerLogger.d('Quantity decreased: ${updatedProduct.quantity}');
    } else {
      providerLogger.w('Cannot decrease quantity below 1');
    }
  }

  void increaseQuantity() {
    if (state.value == null || state.value!.selectedProduct == null) {
      return;
    }
    final selectedProduct = state.value!.selectedProduct!;
    final calculatingProduct = selectedProduct.copyWith(
      quantity: selectedProduct.quantity! + 1,
    );
    final newTotalPrice = _calculateTotalPrice(
      calculatingProduct,
      calculatingProduct.modifierGroups,
      calculatingProduct.extraItemProductVariants,
    );
    final updatedProduct = selectedProduct.copyWith(
      quantity: calculatingProduct.quantity,
      totalPrice: newTotalPrice,
    );
    state = AsyncData(
      state.value!.copyWith(
        selectedProduct: updatedProduct,
      ),
    );
  }

  void setNotesForItem(String notes) {
    if (state.value == null || state.value!.selectedProduct == null) {
      return;
    }
    final selectedProduct = state.value!.selectedProduct!;
    final updatedProduct = selectedProduct.copyWith(
      notesForItem: notes,
    );
    state = AsyncData(
      state.value!.copyWith(
        selectedProduct: updatedProduct,
      ),
    );
  }

  void updateExtraItemQuantity(String extraProductItemId, int newQuantity) {
    if (state.value == null || state.value!.selectedProduct == null) {
      return;
    }

    DetailProduct selectedProduct = state.value!.selectedProduct!;
    if (selectedProduct.extraItemProductVariants != null) {
      final updatedExtraItems =
          selectedProduct.extraItemProductVariants!.map((extraItem) {
        if (extraItem.id == extraProductItemId) {
          return extraItem.copyWith(quantity: newQuantity);
        }
        return extraItem;
      }).toList();

      selectedProduct = selectedProduct.copyWith(
        extraItemProductVariants: updatedExtraItems,
      );

      double newTotalPrice = _calculateTotalPrice(
          selectedProduct, selectedProduct.modifierGroups, updatedExtraItems);

      state = AsyncData(
        state.value!.copyWith(
          selectedProduct: selectedProduct.copyWith(
            totalPrice: newTotalPrice,
          ),
        ),
      );

      providerLogger.d(
          'Extra item quantity updated: $extraProductItemId -> $newQuantity');
    }
  }

  void increaseExtraItemQuantity(String extraProductItemId) {
    if (state.value == null || state.value!.selectedProduct == null) {
      return;
    }

    final selectedProduct = state.value!.selectedProduct!;
    final extraItem = selectedProduct.extraItemProductVariants
        ?.firstWhere((item) => item.id == extraProductItemId);

    if (extraItem != null) {
      final newQuantity = extraItem.quantity + 1;
      updateExtraItemQuantity(extraProductItemId, newQuantity);
    }
  }

  void decreaseExtraItemQuantity(String extraProductItemId) {
    if (state.value == null || state.value!.selectedProduct == null) {
      return;
    }

    final selectedProduct = state.value!.selectedProduct!;
    final extraItem = selectedProduct.extraItemProductVariants
        ?.firstWhere((item) => item.id == extraProductItemId);

    if (extraItem != null && extraItem.quantity > 1) {
      final newQuantity = extraItem.quantity - 1;
      updateExtraItemQuantity(extraProductItemId, newQuantity);
    }
  }
}
