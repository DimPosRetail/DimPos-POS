import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/iterable_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/extensions/string_extension.dart';
import 'package:dimpos_store/features/product/ui/view_models/menu_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomSearchFilterBar extends ConsumerStatefulWidget {
  final String? searchValue;
  final bool isMenuScreen;
  const CustomSearchFilterBar({
    super.key,
    this.searchValue,
    required this.isMenuScreen,
  });

  @override
  ConsumerState<CustomSearchFilterBar> createState() =>
      _CustomSearchFilterBarState();
}

class _CustomSearchFilterBarState extends ConsumerState<CustomSearchFilterBar> {
  late final TextEditingController _searchController;
  final OverlayPortalController _tooltipController = OverlayPortalController();
  final GlobalKey _childCategoriesKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    if (widget.searchValue.isNotNullOrEmpty) {
      _searchController.text = widget.searchValue!;
    }
  }

  @override
  void didUpdateWidget(CustomSearchFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller when searchValue changes from outside
    if (widget.isMenuScreen) {
      final currentSearchQuery =
          ref.read(menuViewModelProvider).value?.searchQuery ?? '';
      if (_searchController.text != currentSearchQuery) {
        _searchController.text = currentSearchQuery;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childCategories =
        ref.watch(menuViewModelProvider).value?.childCategories ?? [];
    return Row(
      spacing: 10.w,
      children: [
        Expanded(
          child: SearchBar(
            controller: _searchController,
            constraints: BoxConstraints(maxHeight: 40.h, minHeight: 40.h),
            backgroundColor: WidgetStateProperty.all(context.buttonTextColor),
            elevation: WidgetStateProperty.all(2),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.w),
              ),
            ),
            hintText: 'Tìm kiếm',
            textStyle: WidgetStateProperty.all(
              context.bodySmall.copyWith(
                color: context.componentNameTextDarkColor,
                fontSize: 14.sp,
              ),
            ),
            trailing: [
              Image.asset(
                Assets.search,
                width: 20.h,
                height: 20.h,
                color: context.onSurfaceColor,
              ),
              SizedBox(width: 10.w),
            ],
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            ),
            onChanged: (value) {
              if (widget.isMenuScreen) {
                ref.read(menuViewModelProvider.notifier).setSearchQuery(value);
              }
            },
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
            },
            shadowColor:
                WidgetStateProperty.all(Color.fromRGBO(186, 186, 186, 0.15)),
          ),
        ),
        //filter child category here
        if (widget.isMenuScreen)
          OverlayPortal(
            controller: _tooltipController,
            overlayChildBuilder: (BuildContext context) {
              return _buildChildCategoriesPanel();
            },
            child: InkWell(
              key: _childCategoriesKey,
              onTap: childCategories.isNotNullOrEmpty
                  ? () {
                      if (!_tooltipController.isShowing) {
                        _tooltipController.show();
                      } else {
                        // Hide overlay
                        _tooltipController.hide();
                      }
                    }
                  : null,
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  shape: BoxShape.circle,
                  boxShadow: [context.boxShadow],
                ),
                child: Image.asset(
                  Assets.filtered,
                  width: 8.w,
                  height: 8.w,
                  color: childCategories.isNotNullOrEmpty
                      ? context.onSurfaceColor
                      : context.onSurfaceColor.withOpacity(0.5),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Offset _getNotificationPosition() {
    final RenderBox? renderBox =
        _childCategoriesKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.localToGlobal(Offset.zero);
    }
    return Offset.zero;
  }

  Widget _buildChildCategoriesPanel() {
    final childCategories =
        ref.watch(menuViewModelProvider).value?.childCategories ?? [];
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _tooltipController.hide();
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        Consumer(
          builder: (context, ref, _) {
            // Assuming MenuViewModel has selectedCategories
            final selectedCategories = ref
                    .watch(menuViewModelProvider)
                    .value
                    ?.selectedChildCategories ??
                [];

            return Positioned(
              top: _getNotificationPosition().dy + 40.h,
              right: MediaQuery.of(context).size.width -
                  _getNotificationPosition().dx -
                  20.w,
              width: 200.w,
              child: GestureDetector(
                onTap: () {},
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(8.w),
                      boxShadow: [context.boxShadow],
                    ),
                    constraints: BoxConstraints(
                      maxHeight: 200.h,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: childCategories.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.all(10.w),
                                  child: Text(
                                    'No categories available',
                                    style: context.bodySmall.copyWith(
                                      color: context.onSurfaceColor,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: childCategories.length,
                                  itemBuilder: (context, index) {
                                    final category = childCategories[index];
                                    final isSelected = selectedCategories
                                        .contains(category.id);

                                    return CheckboxListTile(
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: isSelected,
                                      title: Text(
                                        category.name,
                                        style: context.bodySmall.copyWith(
                                          color: context.onSurfaceColor,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      activeColor: context.primaryColor,
                                      checkColor: context.onPrimaryColor,
                                      onChanged: (bool? value) {
                                        ref
                                            .read(
                                                menuViewModelProvider.notifier)
                                            .toggleChildCategory(category.id);
                                      },
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                    );
                                  },
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 8.h,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(menuViewModelProvider.notifier)
                                    .applyChildCategoryFilter();
                                _tooltipController.hide();
                                // Add logic to apply filters if needed
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primaryColor,
                                foregroundColor: context.onPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.w),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                              ),
                              child: Text(
                                'Áp dụng',
                                style: context.bodySmall.copyWith(
                                  color: context.onPrimaryColor,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
