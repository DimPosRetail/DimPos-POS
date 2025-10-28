import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/common/ui/widgets/show_error_dialog.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:dimpos_store/features/setting/ui/view_models/printer_view_model.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:toastification/toastification.dart';

class PrinterConnectConfirmDialog extends ConsumerStatefulWidget {
  final Printer printer;
  const PrinterConnectConfirmDialog({super.key, required this.printer});

  @override
  ConsumerState<PrinterConnectConfirmDialog> createState() =>
      _PrinterConnectConfirmDialogState();
}

class _PrinterConnectConfirmDialogState
    extends ConsumerState<PrinterConnectConfirmDialog> {
  // late List<Customer> _initialCustomers;
  // TextEditingController? _customerNameSnapshotController;
  String? _validationError;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _initialCustomers = <Customer>[];
    // _customerNameSnapshotController = TextEditingController();
  }

  @override
  void dispose() {
    // _customerNameSnapshotController?.dispose();
    super.dispose();
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
            ? 0.5
            : 0.5;
    double popupHeightPercentTage = isMobile
        ? 0.25
        : isTablet
            ? 0.5
            : 0.3;
    double popupMaxHeight = screenHeight * popupHeightPercentTage;
    double popupMaxWidth = screenWidth * popupWidthPercentTage;
    double popupPaddingHorizon =
        isMobile ? 10.w : 20.w; // Fixed height for each item
    EdgeInsets buttonPadding =
        EdgeInsets.symmetric(vertical: 8.w, horizontal: 8.w);
    EdgeInsets buttonMargin =
        EdgeInsets.symmetric(vertical: 0.w, horizontal: 8.w);
    double buttonFontSize = 16.sp;
    double printerNameFontSize = 20.sp;

    TextStyle buttonTextStyle = context.titleMedium.copyWith(
      color: context.componentNameTextColor,
      fontWeight: FontWeight.w500,
      fontSize: buttonFontSize,
    );
    TextStyle printerNametextStyle = context.titleMedium.copyWith(
      color: context.componentNameTextLighterColor,
      fontWeight: FontWeight.w400,
      fontSize: buttonFontSize,
    );
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  top: 0.h,
                  bottom: isMobile ? 10.h : 20.w,
                  left: popupPaddingHorizon,
                  right: popupPaddingHorizon,
                ),
                child: Text(
                  'Xác nhận lựa chọn máy in',
                  textAlign: TextAlign
                      .center, // Changed from left to center since Container is centered
                  style: context.titleMedium.copyWith(
                    fontSize: 24,
                    color: context.componentNameTextDarkColor,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  widget.printer.name,
                  style: printerNametextStyle,
                ),
              ),
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(),
                height: popupMaxHeight * 0.5,
                child: Center(
                  child: Image.asset(
                    Assets.printer,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: popupPaddingHorizon),
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      // Added Expanded to prevent overflow
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: buttonPadding,
                          margin: buttonMargin,
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            border: Border.all(
                              color: context.componentNameTextLightColor,
                              width: 2.w,
                            ),
                            borderRadius: BorderRadius.circular(
                                8), // Consider adding border radius
                          ),
                          child: Text(
                            'Hủy',
                            style: buttonTextStyle,
                          ), // Add content
                        ),
                      ),
                    ),
                    SizedBox(width: 16), // Add spacing between buttons
                    Expanded(
                      // Added Expanded to prevent overflow
                      child: InkWell(
                        onTap: () async {
                          final choosePrintSuccess = await ref
                              .watch(printerViewModelProvider.notifier)
                              .choosePrinter(widget.printer);
                          if (choosePrintSuccess) {
                            Navigator.of(context).pop();
                          } else {
                            toastification.show(
                              type: ToastificationType.error,
                              style: ToastificationStyle.fillColored,
                              title: Text("Không thể chọn máy in"),
                              description: Text("Lỗi khi chọn máy in"),
                              autoCloseDuration: const Duration(seconds: 3),
                              alignment: Alignment.topRight,
                            );
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: buttonPadding,
                          margin: buttonPadding,
                          decoration: BoxDecoration(
                            color: AppColors.rambutan100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.rambutan100,
                              width: 2.w,
                            ),
                          ),

                          child: Text(
                            'Xác nhận',
                            style: buttonTextStyle.copyWith(
                                color: AppColors.neutral0),
                          ), // Add content
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
