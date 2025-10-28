import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/product/ui/view_models/menu_view_model.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryItemList extends ConsumerStatefulWidget {
  final bool isShrunk;
  const CategoryItemList({super.key, this.isShrunk = false});

  @override
  ConsumerState<CategoryItemList> createState() => _CategoryItemListState();
}

class _CategoryItemListState extends ConsumerState<CategoryItemList> {
  @override
  Widget build(BuildContext context) {
    final products =
        ref.watch(menuViewModelProvider).value?.menu?.products ?? [];
    final categories = ref
            .watch(menuViewModelProvider)
            .value
            ?.menu
            ?.categories
            ?.where(
              (category) => products.any((product) =>
                  product.categoryId == category.id ||
                  category.childCategories?.any((childCategory) =>
                          childCategory.id == product.categoryId) ==
                      true),
            )
            .toList() ??
        [];

    final selectedIndex =
        ref.watch(menuViewModelProvider).value?.selectedCategoryIndex ?? 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return Container(
          padding: EdgeInsets.only(right: 20.w, left: 20.w, top: 10.h),
          decoration: BoxDecoration(
            color: context.containerColor,
          ),
          child: SizedBox(
            height: height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (_, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildCategoryItem(
                    context,
                    'Tất cả',
                    products.length,
                    isShrunk: widget.isShrunk,
                    isSelected: selectedIndex == index,
                    onTap: () => {
                      ref
                          .read(menuViewModelProvider.notifier)
                          .setSelectedCategoryIndex(index),
                    },
                  );
                }

                return _buildCategoryItem(
                  context,
                  categories[index - 1].name,
                  products
                      .where((product) =>
                          product.categoryId == categories[index - 1].id ||
                          categories[index - 1]
                                  .childCategories
                                  ?.singleOrNull
                                  ?.id ==
                              product.categoryId)
                      .length,
                  isShrunk: widget.isShrunk,
                  isSelected: selectedIndex == index,
                  onTap: () => {
                    ref
                        .read(menuViewModelProvider.notifier)
                        .setSelectedCategoryIndex(index),
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String name,
    int quantity, {
    required bool isShrunk,
    required bool isSelected,
    required Function()? onTap,
  }) {
    if (name.isEmpty) return const SizedBox.shrink();
    final isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;

    final categoryName = isShrunk
        ? (name.length > 8 ? '${name.substring(0, 8)}...' : name)
        : (name.length > 10 ? '${name.substring(0, 10)}...' : name);
    final categoryNameFontSize = isMobile ? (isShrunk ? 20.sp : 18.sp) : 16.sp;
    final categoryNameFontWeight = isMobile
        ? (isShrunk ? FontWeight.w400 : FontWeight.w500)
        : FontWeight.w500;

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isMobile ? (150.w) : (180.w),
        // isMobile ? (isShrunk ? 150.w : 90.w) : (isShrunk ? 180.w : 100.w),
        decoration: BoxDecoration(
          // color: context.surfaceColor,
          // color: isSelected ? context.selectedComponentRambutan10 : context.surfaceColor,
          color: isSelected
              ? AppColors.rambutan100.withOpacity(0.1)
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(10.w),
          border: Border.all(
            color: isSelected ? AppColors.rambutan100 : context.containerColor,
            width: 2.w,
          ),
          boxShadow: [context.boxShadow],
        ),
        child: _buildShrunkContent(categoryName, categoryNameFontSize,
            categoryNameFontWeight, isSelected),
        // isShrunk
        //     ? _buildShrunkContent(categoryName, categoryNameFontSize,
        //         categoryNameFontWeight, isSelected)
        //     : _buildFullContent(
        //         categoryName,
        //         categoryNameFontSize,
        //         categoryNameFontWeight,
        //         isSelected,
        //       ),
      ),
    );
  }

  Widget _buildShrunkContent(String categoryName, double categoryFontSize,
      FontWeight categoryFontWeight, bool isSelected) {
    return Row(
      children: [
        // Padding(
        //   padding: const EdgeInsets.only(left: 12.0, right: 8.0),
        //   child: 
        //   Container(
        //     padding: const EdgeInsets.all(8.0),
        //     decoration: BoxDecoration(
        //       color: AppColors.neutral0,
        //       borderRadius: BorderRadius.circular(8.w),
        //       border: Border.all(
        //         color:
        //             isSelected ? AppColors.rambutan100 : context.containerColor,
        //         width: 2.w,
        //       ),
        //     ),
        //     child: Image.asset(
        //       Assets.category,
        //       width: 20.h,
        //       color: isSelected ? AppColors.rambutan100 : AppColors.neutral80,
        //     ),
        //   ),
        // ),
        Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 10.w)),
        Expanded(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: context.titleSmall.copyWith(
              color: isSelected
                  ? AppColors.rambutan100
                  : context.componentNameTextDarkColor,
              fontSize: categoryFontSize,
              fontWeight: categoryFontWeight,
            ),
            child: Text(categoryName, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }

  Widget _buildFullContent(String categoryName, double categoryFontSize,
      FontWeight categoryFontWeight, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.neutral0,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.rambutan100 : AppColors.neutral0,
              width: 2.w,
            ),
          ),
          child: Image.asset(
            Assets.category,
            width: 30.h,
            color: isSelected ? AppColors.rambutan100 : AppColors.neutral80,
          ),
        ),
        SizedBox(height: 18.h),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: context.titleSmall.copyWith(
            color: isSelected ? AppColors.rambutan100 : context.onSurfaceColor,
            fontSize: categoryFontSize,
            fontWeight: categoryFontWeight,
          ),
          child: Text(categoryName, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
