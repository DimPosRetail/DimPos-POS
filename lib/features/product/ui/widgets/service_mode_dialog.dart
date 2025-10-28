import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/iterable_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/common/ui/widgets/show_error_dialog.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/service_mode_view_model.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ServiceModeDialog extends ConsumerWidget {
  final int serviceMethod;
  const ServiceModeDialog({
    super.key,
    required this.serviceMethod,
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
            : 0.4;
    double popupHeightPercentTage = isMobile
        ? 0.3
        : isTablet
            ? 0.35
            : 0.45;
    double popupMaxHeight = screenHeight * popupHeightPercentTage;
    double popupMaxWidth = screenWidth * popupWidthPercentTage;

    double popupPaddingHorizon =
        isMobile ? 10.w : 20.w; // Fixed height for each item
    double popupPaddingVertical =
        isMobile ? 8.w : 16.w; // Fixed height for each item

    // Calculate desired item dimensions based on device type
    int crossAxisCount;
    double desiredHeight;

    if (isMobile) {
      crossAxisCount = 2; // 2 items per row on mobile
      desiredHeight = 120.h; // Your original height
    } else if (isTablet) {
      crossAxisCount = 2; // 3 items per row on tablet
      desiredHeight = 120.h;
    } else {
      crossAxisCount = 2; // More items per row on desktop
      desiredHeight = 120.h;
    }

    // Calculate available width for each grid item (accounting for spacing)
    final horizontalSpacing =
        5.w * (crossAxisCount - 1); // Total spacing between items
    final availableWidth =
        popupMaxWidth - horizontalSpacing - (16.w); // Subtracting padding
    final itemWidth = availableWidth / crossAxisCount;

    final serviceModeViewModel = ref.watch(serviceModeViewModelProvider);
    final cartViewModel = ref.watch(cartViewModelProvider);

    if (serviceModeViewModel.isLoading || cartViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (serviceModeViewModel.hasError || serviceModeViewModel.value == null) {
      return ShowErrorDialog(
        errorMessage: "Đã có lỗi xảy ra khi tải hình thức bán",
      );
    }
    if (cartViewModel.hasError || cartViewModel.value == null) {
      return ShowErrorDialog(errorMessage: "Đã có lỗi xảy ra khi tải giỏ hàng");
    }

    final modesOfService = serviceModeViewModel.value!.modesOfService;

    final carts = cartViewModel.value!.carts;
    final selectedCartIndex = cartViewModel.value!.selectedCartIndex;
    // final cartServiceMode = carts[selectedCartIndex].modeOfService;
    // // if (_initialModeOfService.isNullOrEmpty &&
    // //     cartServiceMode != null &&
    // //     (modesOfService.where((e) => e.value == cartServiceMode)) != null) {
    // //   _initialModeOfService = cartServiceMode;
    // // }
    // final _selectedModeOfService = serviceModeViewModel.value!.selectedModesOfService;

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
                          horizontal: popupPaddingHorizon),
                      child: Text(
                        'Chọn kiểu phục vụ',
                        textAlign: TextAlign.left,
                        style: context.titleMedium.copyWith(
                          fontSize: 16,
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
                          mainAxisExtent: desiredHeight,
                          childAspectRatio: 1,
                          crossAxisSpacing: isMobile ? 10.w : 15.w,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final serviceMode = modesOfService[index];
                            return _serviceModeOptionCard(
                              context,
                              itemWidth,
                              name: serviceMode.display,
                              isSelected: serviceMode.value == serviceMethod,
                              onTap: carts?.isNotNullOrEmpty == true
                                  ? () {
                                      ref
                                          .read(cartViewModelProvider.notifier)
                                          .updateCart(
                                            cartId:
                                                carts![selectedCartIndex].id,
                                            serviceMethod: serviceMode.value,
                                            takeNumberDineIn: null,
                                          );
                                      context.pop();
                                    }
                                  : null,
                            );
                          },
                          childCount: modesOfService.length,
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
  Widget _serviceModeOptionCard(
    BuildContext context,
    double itemWidth, {
    required String name,
    required bool isSelected,
    required Function()? onTap,
  }) {
    final bool isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
    final bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
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
          color: isSelected
              ? AppColors.rambutan100.withOpacity(0.5)
              : context.containerColor,
          border: Border.all(
            color: isSelected ? AppColors.rambutan100 : context.containerColor,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [context.boxShadowDark],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              name,
              style: context.titleSmall.copyWith(
                color: isSelected
                    ? AppColors.neutral10
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
