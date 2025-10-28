import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/common/ui/widgets/show_error_dialog.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MembershipDialog extends ConsumerStatefulWidget {
  const MembershipDialog({super.key});

  @override
  ConsumerState<MembershipDialog> createState() => _MembershipDialogState();
}

class _MembershipDialogState extends ConsumerState<MembershipDialog> {
  // late List<Customer> _initialCustomers;
  TextEditingController? _customerNameSnapshotController;
  String? _validationError;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _initialCustomers = <Customer>[];
    _customerNameSnapshotController = TextEditingController();
  }

  @override
  void dispose() {
    _customerNameSnapshotController?.dispose();
    super.dispose();
  }

  String? _validateCustomerName(String text) {
    final length = text.length;

    if (length < 3) {
      return "Tên khách hàng phải có ít nhất 3 ký tự";
    }
    return null;
  }

  void _handleApplyButtonTap() async {
    final text = _customerNameSnapshotController?.text.trim() ?? "";

    setState(() {
      _validationError = _validateCustomerName(text);
    });

    if (_validationError != null) {
      return;
    }

    try {
      await _handleCustomerNameIntoCart(text);

      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật tên khách hàng: $text'),
            backgroundColor: AppColors.watermelon100,
          ),
        );

        // Đóng dialog
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Hiển thị lỗi nếu có
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleCustomerNameIntoCart(String customerName) async {
    if (customerName.isEmpty) {
      throw Exception('Tên khách hàng không được để trống');
    }

    final cartViewModel = ref.read(cartViewModelProvider);

    if (cartViewModel.value == null) {
      throw Exception('Không thể tải thông tin giỏ hàng');
    }

    final carts = cartViewModel.value!.carts;
    final cartCurrentIndex = cartViewModel.value!.selectedCartIndex;

    if (carts == null || carts.isEmpty) {
      throw Exception('Không có giỏ hàng nào');
    }

    if (cartCurrentIndex < 0 || cartCurrentIndex >= carts.length) {
      throw Exception('Chỉ số giỏ hàng không hợp lệ');
    }

    final currentCart = carts[cartCurrentIndex];

    // if (currentCart == null) {
    //   throw Exception('Không thể tìm thấy giỏ hàng hiện tại');
    // }

    // Gọi method cập nhật
    await ref
        .read(cartViewModelProvider.notifier)
        .updateCartCustomerNameSnapshot(
          cartId: currentCart.id,
          customerNameSnapshot: customerName,
        );
  }

  @override
  Widget build(BuildContext context) {
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
        ? 0.25
        : isTablet
            ? 0.25
            : 0.3;
    double popupMaxHeight = screenHeight * popupHeightPercentTage;
    double popupMaxWidth = screenWidth * popupWidthPercentTage;
    double popupPaddingHorizon =
        isMobile ? 10.w : 20.w; // Fixed height for each item
    double popupPaddingVertical =
        isMobile ? 8.w : 16.w; // Fixed height for each item

    // Calculate desired item dimensions based on device type
    // double desiredHeight;
    // int crossAxisCount;

    // switch (SizeConfig.getDeviceType()) {
    //   case DeviceType.mobile:
    //     crossAxisCount = 1;
    //     desiredHeight = 80.h; // Your original height
    //     break;
    //   case DeviceType.tablet:
    //     crossAxisCount = 1;
    //     desiredHeight = 150.h;
    //     break;
    //   default:
    //     crossAxisCount = 1; // More items per row on desktop
    //     desiredHeight = 180.h;
    //     break;
    // }

    // Calculate available width for each grid item (accounting for spacing)
    // final horizontalSpacing =
    //     5.w * (crossAxisCount - 1); // Total spacing between items
    // final availableWidth = SizeConfig.screenWidth -
    //     horizontalSpacing -
    //     (16.w); // Subtracting padding
    // final itemWidth = availableWidth / crossAxisCount;

    // Calculate the aspect ratio based on desired dimensions
    // final childAspectRatio = (itemWidth / desiredHeight);

    // Tải cart trước
    final cartViewModel = ref.watch(cartViewModelProvider);
    if (cartViewModel.isLoading) {
      return Center(
        child: SizedBox(
          child: CircularProgressIndicator(
            color: AppColors.rambutan100,
          ),
        ),
      );
    }
    if (cartViewModel.hasError || cartViewModel.value == null) {
      return ShowErrorDialog(
        errorMessage: "Đã có lỗi xảy ra khi tải giỏ hàng",
      );
    }

    // final carts = cartViewModel.value!.carts;
    // final cartCurrentIndex = cartViewModel.value!.selectedCartIndex;
    // final currentCart = carts?[cartCurrentIndex];
    // if (currentCart?.customerIdLink.isNotNullOrEmpty == true &&
    //     _initialCustomerId == null) {
    //   _initialCustomerId = currentCart!.customerIdLink!;
    // }

    // final customerViewModel =
    //     ref.watch(membershipViewModelProvider(currentCart?.customerIdLink));

    // if (customerViewModel.isLoading) {
    //   return Center(
    //     child: SizedBox(
    //       child: CircularProgressIndicator(
    //         color: AppColors.rambutan100,
    //       ),
    //     ),
    //   );
    // }
    // if (customerViewModel.hasError || customerViewModel.value == null) {
    //   return ShowErrorDialog(
    //       errorMessage: "Đã có lỗi xảy ra khi tìm khách hàng");
    // }

    // final customers = customerViewModel.value!.searchCustomers;

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
          padding: EdgeInsets.only(
            top: 0.h,
            bottom: isMobile ? 10.h : 10.w,
          ),
          decoration: BoxDecoration(
            color: context.containerDarkerColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: 0.h,
                      bottom: isMobile ? 10.h : 20.w,
                      left: popupPaddingHorizon,
                      right: popupPaddingHorizon,
                      // vertical: isMobile ? 10.h : 20.w,
                      // horizontal: popupPaddingHorizon,
                    ),
                    child: Text(
                      'Khách hàng',
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
                      padding: EdgeInsets.only(
                        top: 0.h,
                        bottom: isMobile ? 10.h : 20.w,
                        left: popupPaddingHorizon,
                        right: popupPaddingHorizon,
                      ),
                      child: const Icon(Icons.close,
                          size: 24, color: Colors.black),
                    ),
                  ),
                ],
              ),
              ...(isMobile
                  ? [
                      Container(
                        padding: EdgeInsets.fromLTRB(popupPaddingHorizon, 0.w,
                            popupPaddingHorizon, popupPaddingVertical),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10.h,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                  maxHeight: 40.h, minHeight: 40.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.w),
                                border: Border.all(
                                  color: context.componentNameTextLighterColor
                                      .withOpacity(0.5),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromRGBO(
                                        186, 186, 186, 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: TextField(
                                controller: _customerNameSnapshotController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 5.h),
                                  border: InputBorder.none,
                                  hintText: "Nhập tên khách hàng",
                                  hintStyle: context.bodySmall.copyWith(
                                    color:
                                        context.componentNameTextLighterColor,
                                    fontSize: isMobile ? 14.sp : 16.sp,
                                  ),
                                ),
                                style: context.bodySmall.copyWith(
                                  color: context.componentNameTextDarkColor,
                                  fontSize: isMobile ? 14.sp : 16.sp,
                                ),
                                keyboardType: TextInputType.name,
                                onTapOutside: (_) =>
                                    FocusScope.of(context).unfocus(),
                              ),
                            ),
                            if (_validationError != null)
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.fromLTRB(
                                    popupPaddingHorizon,
                                    8.h,
                                    popupPaddingHorizon,
                                    0.h),
                                child: Text(
                                  _validationError!,
                                  style: context.bodySmall.copyWith(
                                    color: Colors.red,
                                    fontSize: isMobile ? 12.sp : 14.sp,
                                  ),
                                ),
                              ),
                            InkWell(
                              onTap: _handleApplyButtonTap,
                              child: Container(
                                // width: 40.w,
                                padding: EdgeInsets.symmetric(
                                    horizontal: isMobile
                                        ? 10.w
                                        : isTablet
                                            ? 30.w
                                            : 40.w),
                                alignment: Alignment.center,
                                height: 40.h,
                                decoration: BoxDecoration(
                                    color: AppColors.rambutan100,
                                    borderRadius: BorderRadius.circular(8.w)),
                                child: Text(
                                  "Áp dụng",
                                  style: context.bodySmall.copyWith(
                                    color: AppColors.neutral0,
                                    fontWeight: FontWeight.w500,
                                    fontSize: isMobile
                                        ? 14.sp
                                        : isTablet
                                            ? 16.sp
                                            : 18.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  : [
                      Container(
                        padding: EdgeInsets.fromLTRB(popupPaddingHorizon, 0.w,
                            popupPaddingHorizon, popupPaddingVertical),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10.w,
                          children: [
                            Expanded(
                              child: Container(
                                constraints: BoxConstraints(
                                    maxHeight: 40.h, minHeight: 40.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.w),
                                  border: Border.all(
                                    color: context.componentNameTextLighterColor
                                        .withOpacity(0.5),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromRGBO(
                                          186, 186, 186, 0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: TextField(
                                  controller: _customerNameSnapshotController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 5.h),
                                    border: InputBorder.none,
                                    hintText: "Nhập tên khách hàng",
                                    hintStyle: context.bodySmall.copyWith(
                                      color:
                                          context.componentNameTextLighterColor,
                                      fontSize: isMobile ? 14.sp : 16.sp,
                                    ),
                                  ),
                                  style: context.bodySmall.copyWith(
                                    color: context.componentNameTextDarkColor,
                                    fontSize: isMobile ? 14.sp : 16.sp,
                                  ),
                                  keyboardType: TextInputType.name,
                                  onTapOutside: (_) =>
                                      FocusScope.of(context).unfocus(),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _handleApplyButtonTap,
                              child: Container(
                                // width: 40.w,
                                padding: EdgeInsets.symmetric(
                                    horizontal: isMobile
                                        ? 10.w
                                        : isTablet
                                            ? 30.w
                                            : 40.w),
                                alignment: Alignment.center,
                                height: 40.h,
                                decoration: BoxDecoration(
                                    color: AppColors.rambutan100,
                                    borderRadius: BorderRadius.circular(8.w)),
                                child: Text(
                                  "Áp dụng",
                                  style: context.bodySmall.copyWith(
                                    color: AppColors.neutral0,
                                    fontWeight: FontWeight.w500,
                                    fontSize: isMobile
                                        ? 14.sp
                                        : isTablet
                                            ? 16.sp
                                            : 18.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_validationError != null)
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.fromLTRB(popupPaddingHorizon, 8.h,
                              popupPaddingHorizon, 0.h),
                          child: Text(
                            _validationError!,
                            style: context.bodySmall.copyWith(
                              color: Colors.red,
                              fontSize: isMobile ? 12.sp : 14.sp,
                            ),
                          ),
                        ),
                    ])
            ],
          ),
        ),
      ),
    );
  }

  // This widget represents a single payment method option in the dialog
//   Widget _membershipOption(
//     BuildContext context,
//     double itemWidth,
//     Customer customer, {
//     EdgeInsets? edgeInsets,
//     required bool isSelected,
//     required Function()? onTap,
//   }) {
//     final bool isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
//     final bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
//     final double promotionShortDescriptionSize = isMobile
//         ? 12.sp
//         : isTablet
//             ? 14.sp
//             : 16.sp;
//     final double promotionNameSize = isMobile
//         ? 14.sp
//         : isTablet
//             ? 16.sp
//             : 18.sp;
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         margin: edgeInsets ?? EdgeInsets.all(8.w),
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.rambutan10
//               : context.containerDarkColor.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(10),
//           // boxShadow: [context.boxShadowDark],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // const SizedBox(height: 16),
//             Container(
//               padding: EdgeInsets.only(left: isMobile ? 4.w : 8.w),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
//                     decoration: BoxDecoration(
//                       color: AppColors.rambutan100,
//                       borderRadius: BorderRadius.circular(4.w),
//                     ),
//                     child: Text(
//                       customer.gender,
//                       overflow: TextOverflow.ellipsis,
//                       style: context.titleSmall.copyWith(
//                         color: AppColors.neutral0,
//                         fontSize: promotionShortDescriptionSize,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: isMobile ? 2.h : 4.h,
//                   ),
//                   Text(
//                     customer.fullName,
//                     overflow: TextOverflow.ellipsis,
//                     style: context.titleSmall.copyWith(
//                       color: context.componentNameTextDarkColor,
//                       fontSize: promotionNameSize,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.only(right: isMobile ? 4.w : 8.w),
//               child: Text(
//                 isSelected ? "Đang áp dụng" : "Chọn",
//                 style: context.titleSmall.copyWith(
//                   color: isSelected
//                       ? AppColors.rambutan100
//                       : context.componentNameTextLightColor,
//                   fontSize: promotionNameSize,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
}
