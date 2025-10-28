import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/enums/modifier_group_selected_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/currency_extension.dart';
import 'package:dimpos_store/extensions/iterable_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/extensions/string_extension.dart';
import 'package:dimpos_store/features/common/ui/widgets/show_error_dialog.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/menu_view_model.dart';
import 'package:dimpos_store/features/product/ui/widgets/option_row.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/exception.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductDetailDialog extends ConsumerStatefulWidget {
  const ProductDetailDialog({
    super.key,
  });

  @override
  ConsumerState<ProductDetailDialog> createState() =>
      _ProductDetailDialogState();
}

class _ProductDetailDialogState extends ConsumerState<ProductDetailDialog> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final selectedProduct =
        ref.read(menuViewModelProvider).value?.selectedProduct;
    final note = selectedProduct?.notesForItem;
    _notesController = TextEditingController(text: note ?? '');
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
    final isTablet = SizeConfig.getDeviceType() == DeviceType.mobile;
    final isLandscape = SizeConfig.getOrientation() == Orientation.landscape;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double maxHeight = screenHeight * 0.85;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = screenWidth *
        (isMobile ? 0.4 : (isTablet ? (isLandscape ? 0.6 : 0.8) : 0.6));
    final double itemPadding = 20.w;
    final double borderRadiusConfig = 8.w;
    final double buttonHeight = 32.h;
    final double fontSize = 16.sp;
    final double buttonWidthPercent = 0.25;
    final TextStyle buttonTextStyle = context.titleMedium.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: context.componentNameTextLightColor);
    final menuViewModel = ref.watch(menuViewModelProvider);
    if (menuViewModel.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (menuViewModel.hasError ||
        menuViewModel.value == null ||
        menuViewModel.value!.productsListWithCategory.isNullOrEmpty) {
      return ShowErrorDialog(
        errorMessage: 'Đã có lỗi xảy ra khi tải biến thể sản phẩm.',
      );
    }
    final selectedProduct = menuViewModel.value?.selectedProduct;

    if (selectedProduct == null) {
      return ShowErrorDialog(
        errorMessage: 'Đã có lỗi xảy ra khi tải biến thể sản phẩm.',
      );
    }

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal:
            SizeConfig.getDeviceType() == DeviceType.mobile ? 24.w : 100.w,
        vertical: SizeConfig.getDeviceType() == DeviceType.mobile ? 24.h : 80.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.w),
      ),
      child: Container(
        width: isMobile ? double.infinity : maxWidth,
        height: maxHeight,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(15.w),
        ),
        child: Column(
          children: [
            // Sticky Header
            Container(
              padding:
                  EdgeInsets.fromLTRB(itemPadding, itemPadding, itemPadding, 0),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(15.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image and title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.w),
                          image: DecorationImage(
                            image: (selectedProduct.imageUrl == null ||
                                    selectedProduct.imageUrl!.isEmpty)
                                ? AssetImage(Assets.product2)
                                : NetworkImage(selectedProduct.imageUrl!)
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedProduct.name,
                                        style: context.titleMedium.copyWith(
                                          color: context.onSurfaceColor,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      if (selectedProduct
                                          .description.isNotEmpty)
                                        Text(
                                          selectedProduct.description,
                                          style: context.bodySmall.copyWith(
                                            color: context
                                                .componentNameTextDarkColor,
                                            fontSize: 12.sp,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                if (!isMobile)
                                  InkWell(
                                    onTap: ref
                                                .watch(cartViewModelProvider)
                                                .value
                                                ?.isUpdatingCart ==
                                            true
                                        ? null
                                        : () => Navigator.of(context).pop(),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: context.containerColor,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: EdgeInsets.all(5.w),
                                      child: Icon(
                                        Icons.close,
                                        size: 24.w,
                                        color: context.onSurfaceColor,
                                      ),
                                    ),
                                  )
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (selectedProduct.totalPrice ?? 0)
                                      .round()
                                      .currency,
                                  style: context.titleMedium.copyWith(
                                    color: context.primaryColor,
                                    fontSize: 16.sp,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    _buildQuantityButton(
                                      icon: Icons.remove,
                                      onTap: (selectedProduct.quantity ?? 1) ==
                                              1
                                          ? null
                                          : () {
                                              ref
                                                  .read(menuViewModelProvider
                                                      .notifier)
                                                  .decreaseQuantity();
                                            },
                                    ),
                                    SizedBox(width: 15.w),
                                    Text(
                                      (selectedProduct.quantity).toString(),
                                      style: context.titleMedium.copyWith(
                                        color: context.onSurfaceColor,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    SizedBox(width: 15.w),
                                    _buildQuantityButton(
                                      icon: Icons.add,
                                      onTap: () {
                                        ref
                                            .read(
                                                menuViewModelProvider.notifier)
                                            .increaseQuantity();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Price and quantity controls
                ],
              ),
            ),
            // Scrollable content area
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(itemPadding, itemPadding,
                        itemPadding, 80.h), // Add bottom padding for footer
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          // Size selection
                          if (selectedProduct.variants.isNotNullOrEmpty &&
                              !selectedProduct.isUpdated)
                            _buildSelectionSection(
                              title: 'Chọn kích cỡ',
                              isRequired: true,
                              context: context,
                              child: Column(
                                children: (() {
                                  final sortedVariants = [
                                    ...selectedProduct.variants!
                                  ]..sort((a, b) {
                                      int cmp = a.displayOrder
                                          .compareTo(b.displayOrder);
                                      if (cmp != 0) return cmp;
                                      return a.price.compareTo(b.price);
                                    });
                                  return sortedVariants.map((variant) {
                                    if (variant.size.isNullOrEmpty) {
                                      return Container();
                                    }
                                    return OptionRow(
                                      isRequired: true,
                                      label: variant.size ?? "N/A",
                                      isSelected: variant.isSelected!,
                                      // variant.code.split('-').last,
                                      price: variant.price.currency,
                                      onTap: () {
                                        ref
                                            .read(
                                                menuViewModelProvider.notifier)
                                            .selectVariant(
                                              variant.id,
                                            );
                                      },
                                    );
                                  }).toList();
                                })(),
                              ),
                            ),

                          if (selectedProduct.modifierGroups.isNotNullOrEmpty)
                            ...selectedProduct.modifierGroups!.map((group) {
                              if (group.modifierOptions == null ||
                                  group.modifierOptions.isNullOrEmpty) {
                                return Container();
                              }
                              return _buildSelectionSection(
                                context: context,
                                title: 'Chọn ${group.name.toLowerCase()}',
                                isRequired: false,
                                selectedType: group.selectedType,
                                child: Column(
                                  children: group.modifierOptions!
                                      .map(
                                        (option) => OptionRow(
                                          isRequired: false,
                                          label: option.name,
                                          isSelected: option.isSelected,
                                          price: null,
                                          onTap: () {
                                            ref
                                                .read(menuViewModelProvider
                                                    .notifier)
                                                .selectModifierOption(
                                                  modifierGroupId: group.id,
                                                  modifierOptionId: option.id,
                                                );
                                          },
                                        ),
                                      )
                                      .toList(),
                                ),
                              );
                            }),
                          if (selectedProduct
                              .extraItemProductVariants.isNotNullOrEmpty)
                            _buildSelectionSection(
                              title: 'Các sản phẩm thêm',
                              isRequired: false,
                              context: context,
                              child: Column(
                                children: selectedProduct
                                    .extraItemProductVariants!
                                    .map((item) {
                                  return OptionRow(
                                    isRequired: false,
                                    label: item.name,
                                    isSelected: item.isSelected,
                                    price: item.price.currency,
                                    quantity: item.quantity,
                                    showQuantityInput:
                                        true, // Enable quantity input for extra items
                                    onTap: () {
                                      ref
                                          .read(menuViewModelProvider.notifier)
                                          .selectExtraItem(item.id);
                                    },
                                    onQuantityChanged: (newQuantity) {
                                      ref
                                          .read(menuViewModelProvider.notifier)
                                          .updateExtraItemQuantity(
                                              item.id, newQuantity);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          if (selectedProduct.comboItems.isNotNullOrEmpty)
                            ...selectedProduct.comboItems!.map((comboItem) {
                              List<Widget> widgets = [];

                              // Add combo item title
                              widgets.add(
                                Padding(
                                  padding:
                                      EdgeInsets.only(bottom: 10.h, top: 15.h),
                                  child: Text(
                                    comboItem.productVariant.name,
                                    style: context.titleLarge.copyWith(
                                      color: context.onSurfaceColor,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );

                              // Add modifier groups for this combo item
                              if (comboItem.modifierGroups.isNotNullOrEmpty) {
                                widgets.addAll(
                                  comboItem.modifierGroups!.map((group) {
                                    if (group.modifierOptions == null ||
                                        group.modifierOptions.isNullOrEmpty) {
                                      return Container();
                                    }

                                    return _buildSelectionSection(
                                      context: context,
                                      title: 'Chọn ${group.name.toLowerCase()}',
                                      isRequired: false,
                                      selectedType: group.selectedType,
                                      child: Column(
                                        children: group.modifierOptions!
                                            .map(
                                              (option) => OptionRow(
                                                isRequired: false,
                                                label: option.name,
                                                isSelected: option.isSelected,
                                                price: null,
                                                onTap: () {
                                                  ref
                                                      .read(
                                                          menuViewModelProvider
                                                              .notifier)
                                                      .selectComboModifierOption(
                                                        productVariantId:
                                                            comboItem
                                                                .productVariant
                                                                .id,
                                                        modifierGroupId:
                                                            group.id,
                                                        modifierOptionId:
                                                            option.id,
                                                      );
                                                },
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }

                              return Column(children: widgets);
                            }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Additional notes
            Padding(
              padding:
                  EdgeInsets.fromLTRB(itemPadding, itemPadding, itemPadding, 0),
              child: _buildSelectionSection(
                context: context,
                title: 'Thêm lưu ý',
                isRequired: false,
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Nhập lưu ý của bạn...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.w),
                      borderSide: BorderSide(
                        color: context.componentNameTextDarkColor,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.w),
                      borderSide: BorderSide(
                        color: context.primaryColor,
                        width: 1.0,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: context.onSurfaceColor,
                  ),
                  cursorColor: context.primaryColor,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    ref
                        .read(menuViewModelProvider.notifier)
                        .setNotesForItem(value);
                  },
                  textAlignVertical: TextAlignVertical.top,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            // Sticky Footer
            Container(
              padding:
                  EdgeInsets.fromLTRB(itemPadding, 0, itemPadding, itemPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: isMobile
                          ? (maxWidth - itemPadding * 2)
                          : ((maxWidth - itemPadding * 2) * buttonWidthPercent -
                              4.w),
                      padding: EdgeInsets.symmetric(
                        vertical: ((buttonHeight - fontSize) / 2),
                      ),
                      decoration: BoxDecoration(
                        color: context.containerColor,
                        border: Border.all(
                          color: context.componentNameTextLightColor,
                        ),
                        borderRadius: BorderRadius.circular(
                          borderRadiusConfig,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Hủy",
                        textAlign: TextAlign.center,
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  if (selectedProduct.isUpdated)
                    Expanded(
                      child: InkWell(
                        onTap: ref
                                    .watch(cartViewModelProvider)
                                    .value
                                    ?.isUpdatingCart ==
                                true
                            ? null
                            : () async {
                                try {
                                  // Update the cart with the selected product
                                  await ref
                                      .read(cartViewModelProvider.notifier)
                                      .updateItemToCart(selectedProduct);

                                  if (!context.mounted) return;
                                  context.pop();
                                } catch (e) {
                                  if (!context.mounted) return;
                                  handleApiError(
                                    error: e as DioException,
                                  );
                                }
                              },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: ((buttonHeight - fontSize) / 2),
                          ),
                          decoration: BoxDecoration(
                            color: ref
                                        .watch(cartViewModelProvider)
                                        .value
                                        ?.isUpdatingCart ==
                                    true
                                ? AppColors.rambutan100.withOpacity(0.5)
                                : AppColors.rambutan100,
                            borderRadius: BorderRadius.circular(
                              borderRadiusConfig,
                            ),
                            border: Border.all(
                              color: ref
                                          .watch(cartViewModelProvider)
                                          .value
                                          ?.isUpdatingCart ==
                                      true
                                  ? AppColors.rambutan100.withOpacity(0.5)
                                  : AppColors.rambutan100,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Cập nhập ${isMobile ? "" : "giỏ hàng"} - ${(selectedProduct.totalPrice ?? 0).round().currency}",
                            textAlign: TextAlign.center,
                            style: buttonTextStyle.copyWith(
                              color: AppColors.neutral0,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: InkWell(
                        onTap: ref
                                    .watch(cartViewModelProvider)
                                    .value
                                    ?.isUpdatingCart ==
                                true
                            ? null
                            : () async {
                                try {
                                  await ref
                                      .read(cartViewModelProvider.notifier)
                                      .addItemToCart(selectedProduct);
                                  if (!context.mounted) return;
                                  context.pop();
                                } catch (e) {
                                  if (!context.mounted) return;
                                  handleApiError(
                                    error: e as DioException,
                                  );
                                }
                              },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: ((buttonHeight - fontSize) / 2),
                          ),
                          decoration: BoxDecoration(
                            color: ref
                                        .watch(cartViewModelProvider)
                                        .value
                                        ?.isUpdatingCart ==
                                    true
                                ? AppColors.rambutan100.withOpacity(0.5)
                                : AppColors.rambutan100,
                            borderRadius: BorderRadius.circular(
                              borderRadiusConfig,
                            ),
                            border: Border.all(
                              color: ref
                                          .watch(cartViewModelProvider)
                                          .value
                                          ?.isUpdatingCart ==
                                      true
                                  ? AppColors.rambutan100.withOpacity(0.5)
                                  : AppColors.rambutan100,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Thêm ${isMobile ? "" : "vào giỏ hàng"} - ${(selectedProduct.totalPrice ?? 0).round().currency}",
                            textAlign: TextAlign.center,
                            style: buttonTextStyle.copyWith(
                              color: AppColors.neutral0,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildQuantityButton({
  required IconData icon,
  required VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: 36.w,
      height: 36.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(
        icon,
        size: 20.w,
      ),
    ),
  );
}

Widget _buildSelectionSection({
  required String title,
  required Widget child,
  bool isRequired = false,
  required BuildContext context,
  int? selectedType,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 20.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: context.titleMedium.copyWith(
                color: context.onSurfaceColor,
                fontSize: 16.sp,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: context.containerColor,
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Text(
                isRequired
                    ? 'Bắt buộc, tối đa 1'
                    : (selectedType == ModifierGroupSelectedType.Single.index)
                        ? 'Không bắt buộc, tối đa 1'
                        : 'Không bắt buộc',
                style: context.bodySmall.copyWith(
                  color: context.componentNameTextDarkColor,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        child,
      ],
    ),
  );
}
