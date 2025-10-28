import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/enums/payment_method.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/currency_extension.dart';
import 'package:dimpos_store/extensions/iterable_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/extensions/string_extension.dart';
import 'package:dimpos_store/features/common/ui/widgets/show_error_dialog.dart';
import 'package:dimpos_store/features/order/ui/state/order_state.dart';
import 'package:dimpos_store/features/order/ui/view_models/order_view_model.dart';
import 'package:dimpos_store/features/order/ui/widgets/confirm_cancel_order_dialog.dart';
import 'package:dimpos_store/features/product/models/cart_item.dart';
import 'package:dimpos_store/features/product/models/payment_method.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/financial_shift_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/menu_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/payment_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/store_view_model.dart';
import 'package:dimpos_store/features/product/ui/widgets/payment_status_polling.dart';
import 'package:dimpos_store/features/setting/ui/view_models/printer_view_model.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/exception.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

class PaymentMethodDialog extends ConsumerStatefulWidget {
  const PaymentMethodDialog({super.key});

  @override
  ConsumerState<PaymentMethodDialog> createState() =>
      _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends ConsumerState<PaymentMethodDialog>
    with PaymentStatusPolling {
  // bool _isPaymentSuccessful = false;

  @override
  void dispose() {
    stopPaymentStatusPolling();
    super.dispose();
  }

  Widget _buildSuccessState(
      BuildContext context,
      double popupMaxWidth,
      double popupMaxHeight,
      bool isMobile,
      bool isTablet,
      TextStyle titlePartTextStyle,
      double buttonFontSize,
      double buttonTextPaddingVertical,
      selectedCart,
      storeViewModel,
      PaymentMethod selectedPaymentMethod,
      orderViewModel) {
    return Container(
      width: popupMaxWidth,
      height: popupMaxHeight,
      padding: EdgeInsets.all(isMobile ? 16.w : 20.w),
      decoration: BoxDecoration(
        color: context.containerDarkerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Success icon
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 50.w,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 24.h),

          // Success title
          Text(
            "Thanh toán thành công",
            style: titlePartTextStyle.copyWith(
              color: Colors.green,
              fontSize: isMobile ? 20.sp : 24.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),

          // Order info
          Text(
            "Đơn hàng đã được xác nhận thành công",
            style: context.titleMedium.copyWith(
              fontSize: isMobile ? 14.sp : 16.sp,
              color: context.componentNameTextDarkColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Print receipt button
              InkWell(
                onTap: () {
                  final chosenPrinter =
                      ref.read(printerViewModelProvider).value?.selectedPrinter;
                  if (chosenPrinter != null) {
                    ref
                        .read(printerViewModelProvider.notifier)
                        .printBillInvoice(
                          context: context,
                          selectedCart: selectedCart,
                          storeInfo: storeViewModel.value!.storeInfo!,
                          paymentMethod: selectedPaymentMethod.name,
                          tableNumber: selectedCart.takeNumberDineIn,
                          orderCode:
                              selectedCart.draftOrderCode.split('-').last,
                          isBill: true,
                        );
                  } else {
                    toastification.show(
                      type: ToastificationType.error,
                      style: ToastificationStyle.fillColored,
                      title: Text("Không thể in hóa đơn"),
                      description: Text("Chưa chọn máy in"),
                      autoCloseDuration: const Duration(seconds: 3),
                      alignment: Alignment.topRight,
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: buttonTextPaddingVertical + 4.w,
                    horizontal: buttonTextPaddingVertical + 20.w,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.rambutan100,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: Text(
                    "In hóa đơn",
                    style: context.titleMedium.copyWith(
                      color: AppColors.neutral0,
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),

              // Close button
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: buttonTextPaddingVertical + 4.w,
                    horizontal: buttonTextPaddingVertical + 20.w,
                  ),
                  decoration: BoxDecoration(
                    color: context.containerDarkColor,
                    borderRadius: BorderRadius.circular(12.w),
                    border: Border.all(
                      color: context.disabledColor,
                      width: 1.w,
                    ),
                  ),
                  child: Text(
                    "Đóng",
                    style: context.titleMedium.copyWith(
                      color: context.componentNameTextDarkColor,
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<OrderState>>(orderViewModelProvider,
        (previous, next) {
      if (next.hasValue) {
        final previousOrder = previous?.value?.createdOrder;
        final currentOrder = next.value?.createdOrder;

        if (currentOrder != null) {
          if (currentOrder.paymentMethod == PaymentMethodEnum.qrVietqr.index ||
              currentOrder.paymentMethod == PaymentMethodEnum.qrEdc.index ||
              currentOrder.paymentMethod == PaymentMethodEnum.cardEdc.index ||
              currentOrder.paymentMethod == PaymentMethodEnum.qrPayOs.index) {
            if (previousOrder?.orderId != currentOrder.orderId) {
              startPaymentStatusPolling(
                ref: ref,
                context: context,
                orderId: currentOrder.orderId,
                paymentMethod: currentOrder.paymentMethod,
              );
            }
          }
        } else if (previousOrder != null) {
          stopPaymentStatusPolling();
        }
      }
    });

    SizeConfig.init(context);
    final bool isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
    final bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
    final bool isDesktop = SizeConfig.getDeviceType() == DeviceType.desktop;
    final isLandscape = SizeConfig.getOrientation() == Orientation.landscape;

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double popupWidthPercentTage = isMobile
        ? 1
        : isTablet
            ? isLandscape
                ? 0.8
                : 0.6
            : 0.6;
    double popupHeightPercentTage = isMobile
        ? 1
        : isTablet
            ? 1
            : 1;
    double popupMaxHeight = screenHeight * popupHeightPercentTage;
    double popupMaxWidth = screenWidth * popupWidthPercentTage;
    double popupPaddingHorizon = isMobile ? 12.w : 12.w;
    double popupPadding = 16.w;
    double paymentOptionWidthAndHeightPercentage = isMobile
        ? 0.5
        : isTablet
            ? 0.5
            : 0.45;
    double popupItemVerticalPadding = 4.w;
    double popupItemHorizonalPadding = 10.w;

    TextStyle titlePartTextStyle = context.titleMedium.copyWith(
      fontSize: 24.sp,
      color: context.componentNameTextDarkColor,
    );
    TextStyle cartItemHeaderStyle = context.titleMedium.copyWith(
      color: context.componentNameTextLightColor,
      fontWeight: FontWeight.w400,
      fontSize: 14.sp,
    );
    TextStyle cartItemTextStyle = context.titleMedium.copyWith(
      color: context.componentNameTextDarkColor,
      fontWeight: FontWeight.w400,
      fontSize: 14.sp,
    );
    TextStyle cartPriceTextStyle = context.titleMedium.copyWith(
      color: context.componentNameTextDarkColor,
      fontWeight: FontWeight.w400,
      fontSize: 16.sp,
    );
    TextStyle cartFinalTotalTextStyle = context.titleMedium.copyWith(
      color: context.componentNameTextDarkColor,
      fontWeight: FontWeight.w600,
      fontSize: 16.sp,
    );
    TextStyle inputTitleTextStyle = context.titleMedium.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: context.componentNameTextColor);
    TextStyle inputHintTextStyle = context.titleMedium.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: context.disabledColor,
    );
    TextStyle inputTextStyle = context.titleMedium.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: context.componentNameTextColor,
    );

    double buttonMaxHeight = 32.h;
    double buttonFontSize = 16.sp;
    double buttonTextPaddingVertical = (buttonMaxHeight - buttonFontSize) / 2;
    int crossAxisCount;
    double desiredHeight;
    if (isMobile) {
      crossAxisCount = 2;
      desiredHeight = 100.h;
    } else if (isTablet) {
      crossAxisCount = 3;
      desiredHeight = 200.h;
    } else {
      crossAxisCount = 3;
      desiredHeight = 180.h;
    }

    final horizontalSpacing = 5.w * (crossAxisCount - 1);
    final availableWidth = popupMaxWidth - horizontalSpacing - (16.w);
    final itemWidth = availableWidth / crossAxisCount;
    final childAspectRatio = (itemWidth / desiredHeight);

    final paymentViewModel = ref.watch(paymentViewModelProvider);
    final cartViewModel = ref.watch(cartViewModelProvider);
    final orderViewModel = ref.watch(orderViewModelProvider);
    final storeViewModel = ref.watch(storeViewModelProvider);

    if (paymentViewModel.hasError) {
      return Center(
        child: Text(
          "Lỗi tải phương thức thanh toán",
          style: context.titleMedium.copyWith(color: Colors.red),
        ),
      );
    }
    if (paymentViewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: context.primaryColor,
        ),
      );
    }
    if (paymentViewModel.value == null ||
        paymentViewModel.value!.paymentMethods.isNullOrEmpty) {
      return ShowErrorDialog(
        errorMessage: "Không có phương thức thanh toán nào",
      );
    }

    if (orderViewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: context.primaryColor,
        ),
      );
    }

    if (storeViewModel.value == null) {
      return ShowErrorDialog(
        errorMessage: "Không tìm thấy cửa hàng nào",
      );
    }

    final paymentMethodOptions =
        paymentViewModel.value?.paymentMethods ?? <PaymentMethod>[];
    final selectedPaymentMethodIndex =
        paymentViewModel.value?.selectedPaymentMethod ?? 0;

    // final carts = cartViewModel.value?.carts ?? [];
    final selectedCartIndex = cartViewModel.value?.draftCartIndex ?? 0;
    final selectedCart = cartViewModel.value?.draftOrder;
    // _currentCart = carts[selectedCartIndex];

    final selectedPaymentMethod =
        paymentMethodOptions[selectedPaymentMethodIndex];

    if (selectedCart == null || selectedCart.cartItems.isNullOrEmpty) {
      return Center(
        child: Text(
          "Không có giỏ hàng nào",
          style: context.titleMedium.copyWith(color: Colors.red),
        ),
      );
    }

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 0 : 100.w,
        vertical: isMobile ? 0 : 80.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 0 : 15.w),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [context.boxShadow],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Container(
              width: popupMaxWidth,
              height: popupMaxHeight,
              padding: EdgeInsets.all(popupPaddingHorizon),
              decoration: BoxDecoration(
                color: context.containerDarkerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: (orderViewModel.value?.isPaymentSuccess ?? false)
                  ? _buildSuccessState(
                      context,
                      popupMaxWidth,
                      popupMaxHeight,
                      isMobile,
                      isTablet,
                      titlePartTextStyle,
                      buttonFontSize,
                      buttonTextPaddingVertical,
                      selectedCart,
                      storeViewModel,
                      selectedPaymentMethod,
                      orderViewModel,
                    )
                  : (isDesktop || (isTablet && isLandscape))
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bên trái: danh sách đơn hàng
                            Container(
                              width: paymentOptionWidthAndHeightPercentage *
                                      popupMaxWidth -
                                  popupPadding,
                              padding: EdgeInsets.all(popupPadding),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Xác nhận thanh toán",
                                    textAlign: TextAlign.left,
                                    style: titlePartTextStyle,
                                  ),
                                  SizedBox(height: isMobile ? 8.h : 16.h),
                                  Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(4),
                                      1: FlexColumnWidth(1),
                                      2: FlexColumnWidth(2),
                                    },
                                    children: [
                                      _buildTableRowDivideThree(
                                        context,
                                        Text(
                                          "Tên",
                                          style: cartItemHeaderStyle,
                                          textAlign: TextAlign.left,
                                        ),
                                        Text(
                                          "SL",
                                          style: cartItemHeaderStyle,
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          "Thành tiền",
                                          style: cartItemHeaderStyle,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 1.h,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: popupItemHorizonalPadding +
                                          popupPadding,
                                      vertical: popupItemVerticalPadding,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          context.componentNameTextLighterColor,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(4),
                                          1: FlexColumnWidth(1),
                                          2: FlexColumnWidth(2),
                                        },
                                        children: [
                                          ..._buildCartItemRows(
                                              selectedCart.cartItems!,
                                              context,
                                              cartItemTextStyle),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 1.h,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: popupItemHorizonalPadding +
                                            popupPadding,
                                        vertical: popupItemVerticalPadding),
                                    decoration: BoxDecoration(
                                      color:
                                          context.componentNameTextLighterColor,
                                    ),
                                  ),
                                  _buildTableRowDivideTwo(
                                    context: context,
                                    row1: Text(
                                      "Tạm tính",
                                      style: cartPriceTextStyle,
                                    ),
                                    row2: Text(
                                      selectedCart.subtotalAmount.currency,
                                      style: cartPriceTextStyle.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    verticalPadding: popupItemVerticalPadding,
                                  ),
                                  _buildTableRowDivideTwo(
                                    context: context,
                                    row1: Text(
                                      "Thuế",
                                      style: cartPriceTextStyle,
                                    ),
                                    row2: Text(
                                      '+ ${selectedCart.totalTaxAmount.currency}',
                                      style: cartPriceTextStyle,
                                    ),
                                    verticalPadding: popupItemVerticalPadding,
                                  ),
                                  _buildTableRowDivideTwo(
                                    context: context,
                                    row1: Text(
                                      "Giảm giá",
                                      style: cartPriceTextStyle,
                                    ),
                                    row2: Text(
                                      '- ${(selectedCart.orderLevelDiscountAmount + selectedCart.totalItemDiscountAmount).currency}',
                                      style: cartPriceTextStyle.copyWith(
                                        color: AppColors.rambutan100,
                                      ),
                                    ),
                                    verticalPadding: popupItemVerticalPadding,
                                  ),
                                  Container(
                                    height: 1.h,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: popupItemHorizonalPadding +
                                            popupPadding,
                                        vertical: popupItemVerticalPadding),
                                    decoration: BoxDecoration(
                                      color:
                                          context.componentNameTextLighterColor,
                                    ),
                                  ),
                                  _buildTableRowDivideTwo(
                                    context: context,
                                    row1: Text(
                                      'Tổng cộng',
                                      style: cartFinalTotalTextStyle,
                                    ),
                                    row2: Text(
                                      selectedCart.finalTotalAmount.currency,
                                      style: cartFinalTotalTextStyle.copyWith(
                                        color: AppColors.rambutan100,
                                      ),
                                    ),
                                    verticalPadding: popupItemVerticalPadding,
                                  ),
                                  if (orderViewModel.value?.createdOrder
                                          ?.paymentUrl.isNotNullOrEmpty ==
                                      true) ...[
                                    SizedBox(height: 8.h),
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Quét mã tại đây',
                                        style: context.titleMedium.copyWith(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: context.componentNameTextColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.w),
                                      ),
                                      child: Image.network(
                                        orderViewModel
                                            .value!.createdOrder!.paymentUrl!,
                                        width: 120.w,
                                        height: 120.w,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                  ],
                                  if (orderViewModel.value?.createdOrder !=
                                      null)
                                    Container(
                                      margin: EdgeInsets.only(top: 10.h),
                                      alignment: Alignment.center,
                                      child: InkWell(
                                        onTap: () {
                                          ref
                                              .read(printerViewModelProvider
                                                  .notifier)
                                              .printBillInvoice(
                                                context: context,
                                                selectedCart: selectedCart,
                                                storeInfo: storeViewModel
                                                    .value!.storeInfo!,
                                                paymentMethod:
                                                    selectedPaymentMethod.name,
                                                tableNumber: selectedCart
                                                    .takeNumberDineIn,
                                                qrLink: orderViewModel.value!
                                                    .createdOrder!.paymentUrl,
                                                orderCode: orderViewModel.value!
                                                    .createdOrder!.orderId
                                                    .split('-')
                                                    .last,
                                                isBill: false,
                                              );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: buttonTextPaddingVertical,
                                            horizontal:
                                                buttonTextPaddingVertical +
                                                    10.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.rambutan100,
                                            borderRadius:
                                                BorderRadius.circular(8.w),
                                          ),
                                          child: Text(
                                            "In phiếu thanh toán",
                                            style: context.titleMedium.copyWith(
                                              color: AppColors.neutral0,
                                              fontSize: buttonFontSize,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1.w,
                              height: popupMaxHeight,
                              decoration: BoxDecoration(
                                color: context.componentNameTextLighterColor,
                              ),
                            ),
                            // Bên phải: danh sách chuyển khoản
                            Container(
                              padding: EdgeInsets.all(popupPadding),
                              width:
                                  (1 - paymentOptionWidthAndHeightPercentage) *
                                          popupMaxWidth -
                                      popupPadding,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Phương thức thanh toán",
                                        textAlign: TextAlign.left,
                                        style: titlePartTextStyle,
                                      ),
                                      if (orderViewModel.value?.createdOrder ==
                                          null)
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: context.containerDarkColor,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: const Icon(Icons.close,
                                                size: 24, color: Colors.black),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 16.h),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        CustomScrollView(
                                          slivers: [
                                            SliverPadding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              sliver: SliverGrid(
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      crossAxisCount,
                                                  mainAxisSpacing: 10.w,
                                                  crossAxisSpacing: 10.h,
                                                  childAspectRatio:
                                                      childAspectRatio,
                                                ),
                                                delegate:
                                                    SliverChildBuilderDelegate(
                                                  (context, index) {
                                                    final method =
                                                        paymentMethodOptions[
                                                            index];
                                                    return _paymentMethodOption(
                                                      context,
                                                      itemWidth,
                                                      desiredHeight,
                                                      method,
                                                      isSelected:
                                                          selectedPaymentMethodIndex ==
                                                              index,
                                                      onTap: () {
                                                        ref
                                                            .read(
                                                                paymentViewModelProvider
                                                                    .notifier)
                                                            .setSelectedPaymentMethod(
                                                                index);
                                                      },
                                                    );
                                                  },
                                                  childCount:
                                                      paymentMethodOptions
                                                          .length,
                                                ),
                                              ),
                                            ),
                                            SliverToBoxAdapter(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 20.w,
                                                    horizontal: isMobile
                                                        ? 0.w
                                                        : popupPadding.w),
                                                child: SizedBox(
                                                  height:
                                                      isMobile ? 10.h : 20.h,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (orderViewModel
                                          .value?.createdOrder?.paymentMethod ==
                                      PaymentMethodEnum.cash.index) ...[
                                    SizedBox(
                                      height: 8.h,
                                    ),
                                    Text(
                                      'Tiền khách đưa',
                                      style: inputTitleTextStyle,
                                    ),
                                    Container(
                                      width:
                                          (1 - paymentOptionWidthAndHeightPercentage) *
                                                  popupMaxWidth -
                                              popupPadding,
                                      margin: EdgeInsets.only(
                                          top: 8.h, bottom: 16.h),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.w),
                                        color: context.disabledColor
                                            .withOpacity(0.1),
                                        border: Border.all(
                                          color: context.disabledColor,
                                        ),
                                      ),
                                      child: TextField(
                                        onChanged: (value) {
                                          ref
                                              .read(orderViewModelProvider
                                                  .notifier)
                                              .setAmountPaid(value);
                                        },
                                        keyboardType: TextInputType.number,
                                        style: inputTextStyle,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        decoration: InputDecoration(
                                          hintText: 'Nhập số tiền khách đưa',
                                          hintStyle: inputHintTextStyle,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 12.h,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(Icons.clear),
                                            onPressed: () {
                                              ref
                                                  .read(orderViewModelProvider
                                                      .notifier)
                                                  .setAmountPaid('0');
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (orderViewModel
                                            .value!.createdOrder!.amountPaid <
                                        selectedCart.finalTotalAmount) ...[
                                      Container(
                                        width:
                                            (1 - paymentOptionWidthAndHeightPercentage) *
                                                    popupMaxWidth -
                                                popupPadding,
                                        margin: EdgeInsets.only(bottom: 8.h),
                                        child: Text(
                                          'Số tiền khách đưa phải lớn hơn hoặc bằng tổng tiền',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                    Text(
                                      'Tiền thối',
                                      style: inputTitleTextStyle,
                                    ),
                                    Container(
                                      width:
                                          (1 - paymentOptionWidthAndHeightPercentage) *
                                                  popupMaxWidth -
                                              popupPadding,
                                      margin: EdgeInsets.only(
                                          top: 8.h, bottom: 16.h),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.w),
                                        color: context.disabledColor
                                            .withOpacity(0.1),
                                        border: Border.all(
                                          color: context.disabledColor,
                                        ),
                                      ),
                                      child: Text(
                                        (orderViewModel.value!.createdOrder!
                                                    .amountPaid -
                                                selectedCart.finalTotalAmount)
                                            .currency,
                                        style: inputTextStyle,
                                      ),
                                    ),
                                  ],
                                  if (orderViewModel.value?.createdOrder ==
                                      null)
                                    Container(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              final brandId = ref
                                                  .read(menuViewModelProvider)
                                                  .value
                                                  ?.menu
                                                  ?.brandId;
                                              if (brandId == null) {
                                                ShowErrorDialog(
                                                  errorMessage:
                                                      "Không tìm thấy thương hiệu.",
                                                );
                                                return;
                                              }
                                              final storePaymentMethodConfigId =
                                                  selectedPaymentMethod.id;

                                              try {
                                                await ref
                                                    .read(orderViewModelProvider
                                                        .notifier)
                                                    .createOrder(
                                                      brandId: brandId,
                                                      storePaymentMethodConfigId:
                                                          storePaymentMethodConfigId,
                                                      cart: selectedCart,
                                                      paymentMethod:
                                                          selectedPaymentMethod
                                                              .paymentMethod,
                                                    );
                                                await ref
                                                    .read(cartViewModelProvider
                                                        .notifier)
                                                    .clearCartAfterOrder(
                                                        selectedCartIndex);
                                              } catch (e) {
                                                if (!context.mounted) return;
                                                handleApiError(
                                                  error: e as DioException,
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical:
                                                    buttonTextPaddingVertical,
                                                horizontal:
                                                    buttonTextPaddingVertical +
                                                        20.w,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.rambutan100,
                                                borderRadius:
                                                    BorderRadius.circular(12.w),
                                              ),
                                              child: Text(
                                                "Tiếp tục",
                                                style: context.titleMedium
                                                    .copyWith(
                                                  color: AppColors.neutral0,
                                                  fontSize: buttonFontSize,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (orderViewModel.value?.createdOrder !=
                                      null)
                                    Container(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              final reason =
                                                  await _showConfirmCancelOrderDialog(
                                                context,
                                                orderViewModel.value!
                                                    .createdOrder!.orderId,
                                              );
                                              if (reason.isNotNullOrEmpty) {
                                                if (mounted) {
                                                  (context as Element)
                                                      .findAncestorStateOfType<
                                                          _PaymentMethodDialogState>()
                                                      ?.onOrderCancelled();
                                                }
                                                try {
                                                  await ref
                                                      .read(
                                                          orderViewModelProvider
                                                              .notifier)
                                                      .cancelOrderWhenPayment(
                                                        orderId: orderViewModel
                                                            .value!
                                                            .createdOrder!
                                                            .orderId,
                                                        cancellationReason:
                                                            reason!,
                                                      );
                                                  ref
                                                      .read(
                                                          financialShiftViewModelProvider
                                                              .notifier)
                                                      .getTakedTableNumber();
                                                  if (!context.mounted) {
                                                    return;
                                                  }
                                                  context.pop();
                                                } catch (e) {
                                                  handleApiError(
                                                    error: e as DioException,
                                                  );
                                                }
                                              }
                                            },
                                            child: Container(
                                              alignment: Alignment.centerRight,
                                              padding: EdgeInsets.symmetric(
                                                vertical:
                                                    buttonTextPaddingVertical,
                                                horizontal:
                                                    buttonTextPaddingVertical +
                                                        20.w,
                                              ),
                                              decoration: BoxDecoration(
                                                color: context.disabledColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12.w),
                                                border: Border.all(
                                                  color: context.disabledColor,
                                                  width: 1.w,
                                                ),
                                              ),
                                              child: Text(
                                                "Hủy đơn hàng",
                                                style: context.titleMedium
                                                    .copyWith(
                                                  color: context.disabledColor,
                                                  fontSize: buttonFontSize,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (orderViewModel
                                                      .value!
                                                      .createdOrder!
                                                      .paymentMethod ==
                                                  PaymentMethodEnum
                                                      .cash.index ||
                                              orderViewModel.value
                                                          ?.createdOrder !=
                                                      null &&
                                                  orderViewModel
                                                          .value!
                                                          .createdOrder!
                                                          .paymentMethod !=
                                                      selectedPaymentMethod
                                                          .paymentMethod)
                                            SizedBox(
                                              width: 8.w,
                                            ),
                                          if (orderViewModel
                                                      .value!
                                                      .createdOrder!
                                                      .paymentMethod ==
                                                  PaymentMethodEnum
                                                      .cash.index &&
                                              !(orderViewModel
                                                      .value!
                                                      .createdOrder!
                                                      .paymentMethod !=
                                                  selectedPaymentMethod
                                                      .paymentMethod))
                                            InkWell(
                                              onTap: (orderViewModel
                                                          .value!
                                                          .createdOrder!
                                                          .amountPaid <
                                                      selectedCart
                                                          .finalTotalAmount)
                                                  ? null
                                                  : () async {
                                                      try {
                                                        final orderId =
                                                            orderViewModel
                                                                .value!
                                                                .createdOrder!
                                                                .orderId;
                                                        ref
                                                            .read(
                                                                cartViewModelProvider
                                                                    .notifier)
                                                            .setDraftOrderCode(
                                                                orderId);
                                                        await ref
                                                            .read(
                                                                orderViewModelProvider
                                                                    .notifier)
                                                            .confirmOrderWithCashPayment(
                                                              orderId:
                                                                  orderViewModel
                                                                      .value!
                                                                      .createdOrder!
                                                                      .orderId,
                                                              amountPaid:
                                                                  orderViewModel
                                                                      .value!
                                                                      .createdOrder!
                                                                      .amountPaid,
                                                            );
                                                        if (!context.mounted) {
                                                          return;
                                                        }
                                                        // Set payment successful state
                                                        ref
                                                            .read(
                                                                orderViewModelProvider
                                                                    .notifier)
                                                            .setStatusSuccessPaymentForOrder();
                                                        toastification.show(
                                                          type:
                                                              ToastificationType
                                                                  .success,
                                                          style:
                                                              ToastificationStyle
                                                                  .flatColored,
                                                          title: Text(
                                                              'Tạo đơn hàng thành công!'),
                                                          description: Text(
                                                              'Đơn hàng ${orderViewModel.value!.createdOrder!.orderId.split('-').last} đã được xác nhận thành công.'),
                                                          autoCloseDuration:
                                                              const Duration(
                                                                  seconds: 3),
                                                          alignment: Alignment
                                                              .topRight,
                                                        );
                                                        // Don't pop the dialog, show success state instead
                                                      } catch (e) {
                                                        handleApiError(
                                                          error:
                                                              e as DioException,
                                                        );
                                                      }
                                                    },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  vertical:
                                                      buttonTextPaddingVertical,
                                                  horizontal:
                                                      buttonTextPaddingVertical +
                                                          20.w,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: (orderViewModel
                                                              .value!
                                                              .createdOrder!
                                                              .amountPaid <
                                                          selectedCart
                                                              .finalTotalAmount)
                                                      ? AppColors.rambutan50
                                                      : AppColors.rambutan100,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.w),
                                                ),
                                                child: Text(
                                                  "Xác nhận thanh toán",
                                                  style: context.titleMedium
                                                      .copyWith(
                                                    color: AppColors.neutral0,
                                                    fontSize: buttonFontSize,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (orderViewModel
                                                      .value?.createdOrder !=
                                                  null &&
                                              orderViewModel
                                                      .value!
                                                      .createdOrder!
                                                      .paymentMethod !=
                                                  selectedPaymentMethod
                                                      .paymentMethod)
                                            InkWell(
                                              onTap: () async {
                                                final storePaymentMethodConfigId =
                                                    selectedPaymentMethod.id;

                                                try {
                                                  await ref
                                                      .read(
                                                          orderViewModelProvider
                                                              .notifier)
                                                      .changeOrderPaymentMethod(
                                                        orderId: orderViewModel
                                                            .value!
                                                            .createdOrder!
                                                            .orderId,
                                                        oldStorePaymentMethodConfigId:
                                                            orderViewModel
                                                                .value!
                                                                .createdOrder!
                                                                .storePaymentMethodConfigId,
                                                        newStorePaymentMethodConfigId:
                                                            storePaymentMethodConfigId,
                                                        paymentMethod:
                                                            selectedPaymentMethod
                                                                .paymentMethod,
                                                      );
                                                } catch (e) {
                                                  if (!context.mounted) return;
                                                  handleApiError(
                                                    error: e as DioException,
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  vertical:
                                                      buttonTextPaddingVertical,
                                                  horizontal:
                                                      buttonTextPaddingVertical +
                                                          20.w,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.rambutan100,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.w),
                                                ),
                                                child: Text(
                                                  "Đổi phương thức thanh toán",
                                                  style: context.titleMedium
                                                      .copyWith(
                                                    color: AppColors.neutral0,
                                                    fontSize: buttonFontSize,
                                                    fontWeight: FontWeight.w500,
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
                          ],
                        )
                      : // Replace the mobile section (the else part of `isDesktop ? Row(...) : Column(...)`) with this:
                      // Replace the mobile section (the else part of `isDesktop ? Row(...) : Column(...)`) with this:
                      // Replace the mobile section (the else part of `isDesktop ? Row(...) : Column(...)`) with this:
                      SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Xác nhận thanh toán",
                                    textAlign: TextAlign.left,
                                    style: titlePartTextStyle,
                                  ),
                                  if (orderViewModel.value?.createdOrder ==
                                      null)
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: context.containerDarkColor,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: const Icon(Icons.close,
                                            size: 24, color: Colors.black),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(4),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(2),
                                },
                                children: [
                                  _buildTableRowDivideThree(
                                    context,
                                    Text(
                                      "Tên",
                                      style: cartItemHeaderStyle,
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(
                                      "SL",
                                      style: cartItemHeaderStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      "Thành tiền",
                                      style: cartItemHeaderStyle,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 1.h,
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      popupItemHorizonalPadding + popupPadding,
                                  vertical: popupItemVerticalPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: context.componentNameTextLighterColor,
                                ),
                              ),
                              SizedBox(
                                height: 200.h,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(4),
                                      1: FlexColumnWidth(1),
                                      2: FlexColumnWidth(2),
                                    },
                                    children: [
                                      ..._buildCartItemRows(
                                          selectedCart.cartItems!,
                                          context,
                                          cartItemTextStyle),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 1.h,
                                padding: EdgeInsets.symmetric(
                                    horizontal: popupItemHorizonalPadding +
                                        popupPadding,
                                    vertical: popupItemVerticalPadding),
                                decoration: BoxDecoration(
                                  color: context.componentNameTextLighterColor,
                                ),
                              ),
                              _buildTableRowDivideTwo(
                                context: context,
                                row1: Text(
                                  "Tạm tính",
                                  style: cartPriceTextStyle,
                                ),
                                row2: Text(
                                  selectedCart.subtotalAmount.currency,
                                  style: cartPriceTextStyle.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                verticalPadding: popupItemVerticalPadding,
                              ),
                              _buildTableRowDivideTwo(
                                context: context,
                                row1: Text(
                                  "Thuế",
                                  style: cartPriceTextStyle,
                                ),
                                row2: Text(
                                  '+ ${selectedCart.totalTaxAmount.currency}',
                                  style: cartPriceTextStyle,
                                ),
                                verticalPadding: popupItemVerticalPadding,
                              ),
                              _buildTableRowDivideTwo(
                                context: context,
                                row1: Text(
                                  "Giảm giá",
                                  style: cartPriceTextStyle,
                                ),
                                row2: Text(
                                  '- ${(selectedCart.orderLevelDiscountAmount + selectedCart.totalItemDiscountAmount).currency}',
                                  style: cartPriceTextStyle.copyWith(
                                    color: AppColors.rambutan100,
                                  ),
                                ),
                                verticalPadding: popupItemVerticalPadding,
                              ),
                              Container(
                                height: 1.h,
                                padding: EdgeInsets.symmetric(
                                    horizontal: popupItemHorizonalPadding +
                                        popupPadding,
                                    vertical: popupItemVerticalPadding),
                                decoration: BoxDecoration(
                                  color: context.componentNameTextLighterColor,
                                ),
                              ),
                              _buildTableRowDivideTwo(
                                context: context,
                                row1: Text(
                                  'Tổng cộng',
                                  style: cartFinalTotalTextStyle,
                                ),
                                row2: Text(
                                  selectedCart.finalTotalAmount.currency,
                                  style: cartFinalTotalTextStyle.copyWith(
                                    color: AppColors.rambutan100,
                                  ),
                                ),
                                verticalPadding: popupItemVerticalPadding,
                              ),
                              if (orderViewModel.value?.createdOrder?.paymentUrl
                                      .isNotNullOrEmpty ==
                                  true) ...[
                                SizedBox(height: 8.h),
                                Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Quét mã tại đây',
                                    style: context.titleMedium.copyWith(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: context.componentNameTextColor,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.w),
                                  ),
                                  child: Image.network(
                                    orderViewModel
                                        .value!.createdOrder!.paymentUrl!,
                                    width: 120.w,
                                    height: 120.w,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 20.h),
                              ],
                              if (orderViewModel.value?.createdOrder != null)
                                Container(
                                  margin: EdgeInsets.only(top: 10.h),
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () {
                                      ref
                                          .read(
                                              printerViewModelProvider.notifier)
                                          .printBillInvoice(
                                            context: context,
                                            selectedCart: selectedCart,
                                            storeInfo: storeViewModel
                                                .value!.storeInfo!,
                                            paymentMethod:
                                                selectedPaymentMethod.name,
                                            tableNumber:
                                                selectedCart.takeNumberDineIn,
                                            qrLink: orderViewModel.value!
                                                .createdOrder!.paymentUrl,
                                            orderCode: orderViewModel
                                                .value!.createdOrder!.orderId
                                                .split('-')
                                                .last,
                                            isBill: false,
                                          );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: buttonTextPaddingVertical,
                                        horizontal:
                                            buttonTextPaddingVertical + 10.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.rambutan100,
                                        borderRadius:
                                            BorderRadius.circular(8.w),
                                      ),
                                      child: Text(
                                        "In phiếu thanh toán",
                                        style: context.titleMedium.copyWith(
                                          color: AppColors.neutral0,
                                          fontSize: buttonFontSize,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Container(
                                height: 1.h,
                                margin: EdgeInsets.symmetric(
                                    horizontal: popupItemVerticalPadding,
                                    vertical: popupItemHorizonalPadding),
                                decoration: BoxDecoration(
                                  color: context.componentNameTextLighterColor,
                                ),
                              ),
                              Text(
                                "Phương thức thanh toán",
                                textAlign: TextAlign.left,
                                style: titlePartTextStyle.copyWith(
                                  fontSize: isMobile ? 18.sp : 24.sp,
                                ),
                              ),
                              SizedBox(height: isMobile ? 12.h : 16.h),
                              GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.all(isMobile ? 4.w : 8.w),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: isMobile ? 8.w : 10.w,
                                  crossAxisSpacing: isMobile ? 8.h : 10.h,
                                  childAspectRatio: isMobile
                                      ? 1.8 // Better aspect ratio for mobile
                                      : childAspectRatio,
                                ),
                                itemCount: paymentMethodOptions.length,
                                itemBuilder: (context, index) {
                                  final method = paymentMethodOptions[index];
                                  return _paymentMethodOption(
                                    context,
                                    isMobile
                                        ? (popupMaxWidth - 32.w) /
                                            crossAxisCount
                                        : itemWidth,
                                    isMobile ? 60.h : desiredHeight,
                                    method,
                                    isSelected:
                                        selectedPaymentMethodIndex == index,
                                    onTap: () {
                                      ref
                                          .read(
                                              paymentViewModelProvider.notifier)
                                          .setSelectedPaymentMethod(index);
                                    },
                                  );
                                },
                              ),
                              if (orderViewModel
                                      .value?.createdOrder?.paymentMethod ==
                                  PaymentMethodEnum.cash.index) ...[
                                SizedBox(height: 8.h),
                                Text(
                                  'Tiền khách đưa',
                                  style: inputTitleTextStyle,
                                ),
                                Container(
                                  width: popupMaxWidth - 2 * popupPadding,
                                  margin:
                                      EdgeInsets.only(top: 8.h, bottom: 16.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.w),
                                    color:
                                        context.disabledColor.withOpacity(0.1),
                                    border: Border.all(
                                      color: context.disabledColor,
                                    ),
                                  ),
                                  child: TextField(
                                    onChanged: (value) {
                                      ref
                                          .read(orderViewModelProvider.notifier)
                                          .setAmountPaid(value);
                                    },
                                    keyboardType: TextInputType.number,
                                    style: inputTextStyle,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      hintText: 'Nhập số tiền khách đưa',
                                      hintStyle: inputHintTextStyle,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          ref
                                              .read(orderViewModelProvider
                                                  .notifier)
                                              .setAmountPaid('0');
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                if (orderViewModel
                                        .value!.createdOrder!.amountPaid <
                                    selectedCart.finalTotalAmount) ...[
                                  Container(
                                    width: popupMaxWidth - 2 * popupPadding,
                                    margin: EdgeInsets.only(bottom: 8.h),
                                    child: Text(
                                      'Số tiền khách đưa phải lớn hơn hoặc bằng tổng tiền',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ],
                                Text(
                                  'Tiền thối',
                                  style: inputTitleTextStyle,
                                ),
                                Container(
                                  width: popupMaxWidth - 2 * popupPadding,
                                  margin:
                                      EdgeInsets.only(top: 8.h, bottom: 16.h),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.w),
                                    color:
                                        context.disabledColor.withOpacity(0.1),
                                    border: Border.all(
                                      color: context.disabledColor,
                                    ),
                                  ),
                                  child: Text(
                                    (orderViewModel.value!.createdOrder!
                                                .amountPaid -
                                            selectedCart.finalTotalAmount)
                                        .currency,
                                    style: inputTextStyle,
                                  ),
                                ),
                              ],
                              SizedBox(height: isMobile ? 12.h : 16.h),
                              if (orderViewModel.value?.createdOrder == null)
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.symmetric(
                                            vertical: buttonTextPaddingVertical,
                                            horizontal:
                                                buttonTextPaddingVertical +
                                                    20.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.disabledColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12.w),
                                            border: Border.all(
                                              color: context.disabledColor,
                                              width: 1.w,
                                            ),
                                          ),
                                          child: Text(
                                            "Hủy",
                                            style: context.titleMedium.copyWith(
                                              color: context.disabledColor,
                                              fontSize: buttonFontSize,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      InkWell(
                                        onTap: () async {
                                          final brandId = ref
                                              .read(menuViewModelProvider)
                                              .value
                                              ?.menu
                                              ?.brandId;
                                          if (brandId == null) {
                                            ShowErrorDialog(
                                              errorMessage:
                                                  "Không tìm thấy thương hiệu.",
                                            );
                                            return;
                                          }
                                          final storePaymentMethodConfigId =
                                              selectedPaymentMethod.id;

                                          try {
                                            await ref
                                                .read(orderViewModelProvider
                                                    .notifier)
                                                .createOrder(
                                                  brandId: brandId,
                                                  storePaymentMethodConfigId:
                                                      storePaymentMethodConfigId,
                                                  cart: selectedCart,
                                                  paymentMethod:
                                                      selectedPaymentMethod
                                                          .paymentMethod,
                                                );
                                            await ref
                                                .read(cartViewModelProvider
                                                    .notifier)
                                                .clearCartAfterOrder(
                                                    selectedCartIndex);
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            handleApiError(
                                              error: e as DioException,
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: buttonTextPaddingVertical,
                                            horizontal:
                                                buttonTextPaddingVertical +
                                                    20.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.rambutan100,
                                            borderRadius:
                                                BorderRadius.circular(12.w),
                                          ),
                                          child: Text(
                                            "Tiếp tục",
                                            style: context.titleMedium.copyWith(
                                              color: AppColors.neutral0,
                                              fontSize: buttonFontSize,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (orderViewModel.value?.createdOrder != null)
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          final reason =
                                              await _showConfirmCancelOrderDialog(
                                            context,
                                            orderViewModel
                                                .value!.createdOrder!.orderId,
                                          );
                                          if (reason.isNotNullOrEmpty) {
                                            if (mounted) {
                                              (context as Element)
                                                  .findAncestorStateOfType<
                                                      _PaymentMethodDialogState>()
                                                  ?.onOrderCancelled();
                                            }
                                            try {
                                              await ref
                                                  .read(orderViewModelProvider
                                                      .notifier)
                                                  .cancelOrderWhenPayment(
                                                    orderId: orderViewModel
                                                        .value!
                                                        .createdOrder!
                                                        .orderId,
                                                    cancellationReason: reason!,
                                                  );
                                              if (!context.mounted) {
                                                return;
                                              }
                                              context.pop();
                                            } catch (e) {
                                              handleApiError(
                                                error: e as DioException,
                                              );
                                            }
                                          }
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.symmetric(
                                            vertical:
                                                buttonTextPaddingVertical + 5.h,
                                            horizontal:
                                                buttonTextPaddingVertical +
                                                    20.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.disabledColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12.w),
                                            border: Border.all(
                                              color: context.disabledColor,
                                              width: 1.w,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Hủy đơn hàng",
                                              style:
                                                  context.titleMedium.copyWith(
                                                color: context.disabledColor,
                                                fontSize: buttonFontSize,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      if (orderViewModel.value!.createdOrder!
                                                  .paymentMethod ==
                                              PaymentMethodEnum.cash.index &&
                                          !(orderViewModel.value!.createdOrder!
                                                  .paymentMethod !=
                                              selectedPaymentMethod
                                                  .paymentMethod))
                                        InkWell(
                                          onTap: (orderViewModel
                                                      .value!
                                                      .createdOrder!
                                                      .amountPaid <
                                                  selectedCart.finalTotalAmount)
                                              ? null
                                              : () async {
                                                  try {
                                                    final orderId =
                                                        orderViewModel
                                                            .value!
                                                            .createdOrder!
                                                            .orderId;
                                                    ref
                                                        .read(
                                                            cartViewModelProvider
                                                                .notifier)
                                                        .setDraftOrderCode(
                                                            orderId);
                                                    await ref
                                                        .read(
                                                            orderViewModelProvider
                                                                .notifier)
                                                        .confirmOrderWithCashPayment(
                                                          orderId:
                                                              orderViewModel
                                                                  .value!
                                                                  .createdOrder!
                                                                  .orderId,
                                                          amountPaid:
                                                              orderViewModel
                                                                  .value!
                                                                  .createdOrder!
                                                                  .amountPaid,
                                                        );
                                                    if (!context.mounted) {
                                                      return;
                                                    }
                                                    // Set payment successful state
                                                    ref
                                                        .read(
                                                            orderViewModelProvider
                                                                .notifier)
                                                        .setStatusSuccessPaymentForOrder();
                                                    toastification.show(
                                                      type: ToastificationType
                                                          .success,
                                                      style: ToastificationStyle
                                                          .flatColored,
                                                      title: Text(
                                                          'Tạo đơn hàng thành công!'),
                                                      description: Text(
                                                          'Đơn hàng ${orderViewModel.value!.createdOrder!.orderId.split('-').last} đã được xác nhận thành công.'),
                                                      autoCloseDuration:
                                                          const Duration(
                                                              seconds: 3),
                                                      alignment:
                                                          Alignment.topRight,
                                                    );
                                                    // Don't pop the dialog, show success state instead
                                                  } catch (e) {
                                                    handleApiError(
                                                      error: e as DioException,
                                                    );
                                                  }
                                                },
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                              vertical:
                                                  buttonTextPaddingVertical +
                                                      5.h,
                                              horizontal:
                                                  buttonTextPaddingVertical +
                                                      20.w,
                                            ),
                                            decoration: BoxDecoration(
                                              color: (orderViewModel
                                                          .value!
                                                          .createdOrder!
                                                          .amountPaid <
                                                      selectedCart
                                                          .finalTotalAmount)
                                                  ? AppColors.rambutan50
                                                  : AppColors.rambutan100,
                                              borderRadius:
                                                  BorderRadius.circular(12.w),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Xác nhận thanh toán",
                                                style: context.titleMedium
                                                    .copyWith(
                                                  color: AppColors.neutral0,
                                                  fontSize: buttonFontSize,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (orderViewModel.value?.createdOrder !=
                                              null &&
                                          orderViewModel.value!.createdOrder!
                                                  .paymentMethod !=
                                              selectedPaymentMethod
                                                  .paymentMethod)
                                        InkWell(
                                          onTap: () async {
                                            final storePaymentMethodConfigId =
                                                selectedPaymentMethod.id;

                                            try {
                                              await ref
                                                  .read(orderViewModelProvider
                                                      .notifier)
                                                  .changeOrderPaymentMethod(
                                                    orderId: orderViewModel
                                                        .value!
                                                        .createdOrder!
                                                        .orderId,
                                                    oldStorePaymentMethodConfigId:
                                                        orderViewModel
                                                            .value!
                                                            .createdOrder!
                                                            .storePaymentMethodConfigId,
                                                    newStorePaymentMethodConfigId:
                                                        storePaymentMethodConfigId,
                                                    paymentMethod:
                                                        selectedPaymentMethod
                                                            .paymentMethod,
                                                  );
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              handleApiError(
                                                error: e as DioException,
                                              );
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                              vertical:
                                                  buttonTextPaddingVertical +
                                                      5.h,
                                              horizontal:
                                                  buttonTextPaddingVertical +
                                                      20.w,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.rambutan100,
                                              borderRadius:
                                                  BorderRadius.circular(12.w),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Đổi phương thức thanh toán",
                                                style: context.titleMedium
                                                    .copyWith(
                                                  color: AppColors.neutral0,
                                                  fontSize: buttonFontSize,
                                                  fontWeight: FontWeight.w500,
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
            ),
            if (orderViewModel.value?.isLoading ?? false)
              Positioned.fill(
                child: Container(
                  color: context.containerColor.withOpacity(0.8),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<TableRow> _buildCartItemRows(List<CartItem> cartItems,
      BuildContext context, TextStyle cartItemTextStyle) {
    final List<TableRow> rows = [];

    // Group cart items by their main product and extra items
    // CartItems have extraItems as a property, not separate items like OrderItems
    for (var item in cartItems) {
      // Add main product row
      rows.add(
        _buildTableRowDivideThree(
          context,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productVariantNameSnapshot,
                style: cartItemTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.left,
              ),
              if (item.modifierGroupItems.isNotNullOrEmpty)
                ...item.modifierGroupItems!.map(
                  (modifier) => Text(
                    "• ${modifier.modifierOptionSnapshot}",
                    style: cartItemTextStyle.copyWith(
                      fontSize: 12.sp,
                      color: context.componentNameTextLighterColor,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
            ],
          ),
          Text(
            "x${item.quantity}",
            style: cartItemTextStyle,
            textAlign: TextAlign.center,
          ),
          Text(
            item.itemSubtotalAmount.currency,
            style: cartItemTextStyle,
            textAlign: TextAlign.right,
          ),
        ),
      );

      // Add extra items rows if they exist
      if (item.extraItems.isNotNullOrEmpty) {
        for (var extraItem in item.extraItems!) {
          rows.add(
            _buildTableRowDivideThree(
              context,
              Text(
                "+ ${extraItem.extraProductVariantNameSnapshot}",
                style: cartItemTextStyle.copyWith(
                  fontSize: 12.sp,
                  color: context.componentNameTextLighterColor,
                ),
                textAlign: TextAlign.left,
              ),
              Text(
                "x${extraItem.quantity}",
                style: cartItemTextStyle.copyWith(
                  fontSize: 12.sp,
                  color: context.componentNameTextLighterColor,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                (extraItem.unitPriceAtAdditionSnapshot * extraItem.quantity)
                    .currency,
                style: cartItemTextStyle.copyWith(
                  fontSize: 12.sp,
                  color: context.componentNameTextLighterColor,
                ),
                textAlign: TextAlign.right,
              ),
              isExtraItem: true,
            ),
          );
        }
      }
    }

    return rows;
  }
}

Widget _buildTableRowDivideTwo({
  Text? row1,
  Text? row2,
  double? verticalPadding,
  double? horizonalPadding,
  bool hasTopBorder = false,
  bool hasBottomBorder = false,
  required BuildContext context,
}) {
  final BoxDecoration decoration = BoxDecoration(
    border: Border(
      bottom: hasBottomBorder
          ? BorderSide(
              color: context.componentNameTextDarkColor,
              width: 1,
            )
          : BorderSide(
              color: Colors.transparent,
            ),
      top: hasTopBorder
          ? BorderSide(
              color: context.componentNameTextDarkColor,
              width: 1,
            )
          : BorderSide(
              color: Colors.transparent,
            ),
    ),
  );
  return Container(
    decoration: decoration,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizonalPadding ?? 0.w,
        vertical: verticalPadding ?? 0.w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          row1 ?? Container(),
          row2 ?? Container(),
        ],
      ),
    ),
  );
}

TableRow _buildTableRowDivideThree(
  BuildContext context,
  Widget row1,
  Widget row2,
  Widget row3, {
  bool hasTopBorder = false,
  bool hasBottomBorder = false,
  Color? borderColor,
  bool isExtraItem = false,
}) {
  final double rowPaddingHeight = isExtraItem ? 0 : 4.w;
  final BoxDecoration decoration = BoxDecoration(
    border: Border(
      bottom: hasBottomBorder
          ? BorderSide(
              color: borderColor ?? context.componentNameTextDarkColor,
              width: 1,
            )
          : BorderSide(
              color: Colors.transparent,
            ),
      top: hasTopBorder
          ? BorderSide(
              color: borderColor ?? context.componentNameTextDarkColor,
              width: 1,
            )
          : BorderSide(
              color: Colors.transparent,
            ),
    ),
  );
  return TableRow(
    decoration: decoration,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: rowPaddingHeight),
        child: row1,
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: rowPaddingHeight),
        child: row2,
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: rowPaddingHeight),
        child: row3,
      ),
    ],
  );
}

Row buildTwoButtonRow(
  BuildContext context,
  double itemWidth,
  double itemPaddingWidth, {
  Icon? firstButtonIcon,
  Icon? secondButtonIcon,
  Text? firstButtonText,
  Text? secondButtonText,
  BoxDecoration? firstButtonDecoration,
  BoxDecoration? secondButtonDecoration,
  double? firstButtonWidth,
  double? secondButtonWidth,
  required Function() onFirstButtonTap,
  required Function() onSecondButtonTap,
  required bool isEnabled,
}) {
  final double firstButtonSize = firstButtonIcon?.size ?? 0;
  final double firstButtonPadding = 12.w;
  final double componentSpacing = 8.w;
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      InkWell(
        onTap: onFirstButtonTap,
        child: Container(
          padding: EdgeInsets.all(firstButtonPadding),
          decoration: firstButtonDecoration ??
              BoxDecoration(
                color: isEnabled
                    ? context.containerLighterColor
                    : context.containerDarkColor,
                borderRadius: BorderRadius.circular(10.w),
                border: Border.all(
                  color: isEnabled
                      ? AppColors.rambutan100
                      : context.disabledColorDarker,
                  width: 1.w,
                ),
              ),
          child: (firstButtonIcon != null)
              ? firstButtonIcon
              : ((firstButtonText != null) ? firstButtonText : Container()),
        ),
      ),
      SizedBox(width: componentSpacing),
      InkWell(
        onTap: onSecondButtonTap,
        child: Container(
          padding: EdgeInsets.all(12.w),
          width: (itemWidth -
              itemPaddingWidth * 2 -
              firstButtonSize -
              2 * firstButtonPadding -
              componentSpacing -
              2.w),
          decoration: secondButtonDecoration ??
              BoxDecoration(
                color: isEnabled
                    ? context.containerLighterColor
                    : context.disabledColor,
                borderRadius: BorderRadius.circular(10.w),
                border: Border.all(
                  color: isEnabled
                      ? AppColors.rambutan100
                      : context.disabledColorDarker,
                  width: 1.w,
                ),
              ),
          child: (secondButtonIcon != null)
              ? firstButtonIcon
              : ((secondButtonText != null) ? secondButtonText : Container()),
        ),
      ),
    ],
  );
}

Widget _paymentMethodOption(
  BuildContext context,
  double itemWidth,
  double itemHeight,
  PaymentMethod paymentMethod, {
  required bool isSelected,
  required Function()? onTap,
}) {
  final bool isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
  final bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
  final double imageWidth = isMobile
      ? itemWidth * 0.2
      : isTablet
          ? itemWidth * 0.1
          : itemWidth * 0.1;

  final double fontSize = isMobile
      ? 14.sp
      : isTablet
          ? 14.sp
          : 16.sp;
  final paymentMethodNameTextStyle = context.titleSmall.copyWith(
      color: isSelected
          ? AppColors.rambutan100
          : context.componentNameTextDarkColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w400);
  final String configPaymentMenthodName = paymentMethod.name;
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.rambutan10 : context.containerColor,
        border: Border.all(
          color: isSelected ? AppColors.rambutan100 : context.disabledColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10.w),
        boxShadow: [context.boxShadowDark],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.w),
            child: FadeInImage.assetNetwork(
              placeholder: Assets.cash,
              image: paymentMethod.logoUrl ?? "",
              fit: BoxFit.cover,
              width: imageWidth,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  Assets.imageNotFound,
                  width: imageWidth,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                top: isMobile
                    ? 2.h
                    : isTablet
                        ? 4.h
                        : 6.h),
            child: Text(
              configPaymentMenthodName,
              style: paymentMethodNameTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

Future<String?> _showConfirmCancelOrderDialog(
    BuildContext context, String orderId) async {
  return await showDialog<String?>(
    context: context,
    builder: (BuildContext context) {
      return ConfirmCancelOrderDialog(
        orderId: orderId,
      );
    },
  );
}
