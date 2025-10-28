import 'package:dimpos_store/enums/mode_of_service.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/features/common/models/display_item.dart';
import 'package:dimpos_store/features/common/ui/widgets/show_error_dialog.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/financial_shift_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/table_view_model.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:go_router/go_router.dart';

class TableDialog extends ConsumerWidget {
  final int takeNumberDineIn;
  const TableDialog({
    super.key,
    required this.takeNumberDineIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    final bool isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
    final bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double popupWidthPercentTage = isMobile
        ? 1
        : isTablet
            ? 0.6
            : 0.5;
    double popupHeightPercentTage = isMobile
        ? 0.5
        : isTablet
            ? 0.6
            : 0.85;
    double popupMaxHeight = screenHeight * popupHeightPercentTage;
    double popupMaxWidth = screenWidth * popupWidthPercentTage;
    double popupPaddingHorizon =
        isMobile ? 10.w : 20.w; // Fixed height for each item
    double popupPaddingVertical =
        isMobile ? 8.w : 16.w; // Fixed height for each item

    // Calculate desired item dimensions based on device type
    int crossAxisCount;

    switch (SizeConfig.getDeviceType()) {
      case DeviceType.mobile:
        crossAxisCount = 3;
        break;
      case DeviceType.tablet:
        crossAxisCount = 4;
        break;
      default:
        crossAxisCount = 5; // More items per row on desktop
        break;
    }

    // Calculate available width for each grid item (accounting for spacing)
    final horizontalSpacing =
        5.w * (crossAxisCount - 1); // Total spacing between items
    final availableWidth = SizeConfig.screenWidth -
        horizontalSpacing -
        (16.w); // Subtracting padding
    final itemWidth = availableWidth / crossAxisCount;

    final tableViewModel = ref.watch(tableViewModelProvider);
    final cartViewModel = ref.watch(cartViewModelProvider);
    final existingTableNumbers =
        ref.watch(financialShiftViewModelProvider).value?.takedTableNumber;

    if (tableViewModel.isLoading || cartViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tableViewModel.hasError ||
        tableViewModel.value == null ||
        existingTableNumbers == null) {
      return ShowErrorDialog(
        errorMessage: 'Đã có lỗi xảy ra khi tải bàn',
      );
    }
    if (cartViewModel.hasError || cartViewModel.value == null) {
      return ShowErrorDialog(
        errorMessage: 'Đã có lỗi xảy ra khi tải giỏ hàng',
      );
    }

    final tables = tableViewModel.value!.tables;
    final carts = cartViewModel.value!.carts;
    final selectedCartIndex = cartViewModel.value!.selectedCartIndex;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24.w : 100.w,
        vertical: isMobile ? 24.h : 80.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.w),
      ),
      child: Container(
        width: popupMaxWidth,
        height: popupMaxHeight,
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [context.boxShadow],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: popupMaxWidth,
          padding: EdgeInsets.all(popupPaddingHorizon),
          decoration: BoxDecoration(
            color: context.containerDarkerColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(popupPaddingVertical),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        // vertical: isMobile ? 10.h : 10.w,
                        horizontal: popupPaddingHorizon,
                      ),
                      child: Text(
                        'Chọn số bàn',
                        textAlign: TextAlign.left,
                        style: context.titleMedium.copyWith(
                          fontSize: 24,
                          color: context.componentNameTextDarkColor,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: popupPaddingHorizon),
                        child: const Icon(Icons.close,
                            size: 24, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                // padding: const EdgeInsets.all(8.0),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.all(popupPaddingVertical),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: isMobile ? 10.w : 15.w,
                          childAspectRatio: 1,
                          crossAxisSpacing: isMobile ? 10.w : 15.w,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final table = tables[index];
                            return _tableOptionCard(
                              context,
                              itemWidth,
                              table,
                              isSelected: takeNumberDineIn == (index + 1),
                              // _selectedTable == index,
                              onTap: existingTableNumbers.contains(index + 1)
                                  ? null
                                  : () {
                                      context.pop();
                                      ref
                                          .read(cartViewModelProvider.notifier)
                                          .updateCart(
                                            takeNumberDineIn: index + 1,
                                            cartId:
                                                carts![selectedCartIndex].id,
                                            serviceMethod:
                                                ModeOfService.DineIn.index,
                                          );
                                    },
                              isDisabled:
                                  existingTableNumbers.contains(index + 1),
                            );
                          },
                          childCount: tables.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // This widget represents a single payment method option in the dialog
  Widget _tableOptionCard(
    BuildContext context,
    double itemWidth,
    DisplayItem displayItem, {
    required bool isSelected,
    bool isDisabled = false,
    required Function()? onTap,
  }) {
    final bool isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
    final bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
    final int maxcustomerNameLength = isMobile
        ? 8
        : (isTablet ? 12 : 14); // Maximum length of payment method name
    final double fontSize = isMobile
        ? 14.sp
        : isTablet
            ? 16.sp
            : 18.sp; // Adjust font size based on device type F
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.rambutan10 : context.containerColor,
          border: Border.all(
            color: (isSelected && isDisabled)
                ? AppColors.rambutan100.withOpacity(0.5)
                : isSelected
                    ? AppColors.rambutan100
                    : isDisabled
                        ? context.componentNameTextLighterColor.withOpacity(0.5)
                        : context.componentNameTextLighterColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [context.boxShadowDark],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              (displayItem.display.length > maxcustomerNameLength)
                  ? '${displayItem.display.substring(0, maxcustomerNameLength)}...'
                  : displayItem.display,
              style: context.titleSmall.copyWith(
                color: isDisabled
                    ? context.componentNameTextDarkColor.withOpacity(0.5)
                    : context.componentNameTextDarkColor,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
