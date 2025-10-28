import 'package:dimpos_store/constants/language.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/enums/mode_of_service.dart';
import 'package:dimpos_store/enums/order_status.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/currency_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/extensions/string_extension.dart';
import 'package:dimpos_store/features/common/ui/widgets/show_error_dialog.dart';
import 'package:dimpos_store/features/order/models/order_item.dart';
import 'package:dimpos_store/features/order/ui/view_models/order_view_model.dart';
import 'package:dimpos_store/features/order/ui/widgets/confirm_cancel_order_dialog.dart';
import 'package:dimpos_store/features/product/ui/view_models/financial_shift_view_model.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/exception.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailDialog extends ConsumerWidget {
  final String orderId;
  const OrderDetailDialog({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Config size of the component
    SizeConfig.init(context);
    final bool isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
    final bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
    final isMobile2 = SizeConfig.getDeviceType() == DeviceType.mobile ||
        SizeConfig.getDeviceType() == DeviceType.tablet;
    final isDesktop = SizeConfig.getDeviceType() == DeviceType.desktop;
    final isLandscape = SizeConfig.isLandscape();

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double popupWidthPercentTage = isMobile
        ? 1
        : isTablet
            ? (isLandscape ? 0.8 : 0.6)
            : 0.6;
    // double popupHeightPercentTage = isMobile
    //     ? 0.86
    //     : isTablet
    //         ? 0.81
    //         : 0.6;
    double popupMaxHeight = screenHeight;
    double popupMaxWidth = screenWidth * popupWidthPercentTage;
    double popupContentMaxHeight = isMobile
        ? popupMaxWidth * 0.65
        : isTablet
            ? popupMaxWidth * (isLandscape?0.255:0.6)
            : popupMaxWidth * 0.35;
    double popupPaddingHorizon =
        isMobile ? 10.w : 12.w; // Fixed height for each item
    double popupPaddingVertical =
        isMobile ? 8.w : 16.w; // Fixed height for each itemch item
    double popupPadding = isMobile ? 12.w : 16.w; // Fixed height for each item
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
    // TextStyle cartPriceTextStyle = context.titleMedium.copyWith(
    //   color: context.componentNameTextDarkColor,
    //   fontWeight: FontWeight.w400,
    //   fontSize: 16.sp,
    // );
    TextStyle cartFinalTotalTextStyle = context.titleMedium.copyWith(
      color: context.componentNameTextDarkColor,
      fontWeight: FontWeight.w600,
      fontSize: 16.sp,
    );
    // TextStyle inputTitleTextStyle = context.titleMedium.copyWith(
    //     fontSize: 16.sp,
    //     fontWeight: FontWeight.w600,
    //     color: context.componentNameTextColor);

    double buttonMaxHeight = 32.h;
    double buttonFontSize = 16.sp;
    // double buttonTextPaddingVertical = (buttonMaxHeight - buttonFontSize) / 2;
    TextStyle buttonTextStyle = context.titleMedium.copyWith(
      color: AppColors.neutral0,
      fontWeight: FontWeight.w400,
      fontSize: buttonFontSize,
    );

    final orderViewModel = ref.watch(orderViewModelProvider);
    if (orderViewModel.isLoading || orderViewModel.value?.isLoading == true) {
      return Center(
        child: SizedBox(
          width: 40.w,
          height: 40.h,
          child: CircularProgressIndicator(
            color: AppColors.rambutan100,
          ),
        ),
      );
    }
    if (orderViewModel.hasError || orderViewModel.value == null) {
      return ShowErrorDialog(
        errorMessage: "Đã có lỗi xảy ra khi tải đơn hàng",
      );
    }

    final currentOrder = orderViewModel.value!.selectedOrder;
    if (orderViewModel.value!.selectedOrder == null) {
      return Center(
        child: SizedBox(
          width: 40.w,
          height: 40.h,
          child: CircularProgressIndicator(
            color: AppColors.rambutan100,
          ),
        ),
      );
    }
    // if (currentOrder!.customerId.isNotNullOrEmpty) {
    //   ref
    //       .read(orderViewModelProvider.notifier)
    //       .setSelectedOrderCustomer(currentOrder.customerId!);
    // }

    final orderStatus = OrderStatus.values.firstWhere(
      (status) => status.index == currentOrder!.status,
    );
    Color? statusColor;
    switch (orderStatus) {
      case OrderStatus.PendingPayment:
        statusColor = AppColors.cempedak100;
        break;
      case OrderStatus.Confirmed:
        statusColor = AppColors.blueberry100;
        break;
      case OrderStatus.ReadyForPickup:
        statusColor = AppColors.teal100;
        break;
      case OrderStatus.Completed:
        statusColor = AppColors.greenMint100;
        break;
      case OrderStatus.Cancelled:
        statusColor = AppColors.rambutan100;
        break;
    }
    final orderStatusTextStyle = context.titleMedium.copyWith(
      color: statusColor,
      fontWeight: FontWeight.w400,
      fontSize: 14.sp,
    );
    final orderStatusBoxDecoration = BoxDecoration(
      color: statusColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4.w),
    );

    // final currentOrderCustomer = orderViewModel.value!.selectedOrder;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24.w : 100.w,
        vertical: isMobile ? 24.h : 80.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.w),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              boxShadow: [context.boxShadow],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: popupMaxWidth,
              height: popupMaxHeight,
              padding: EdgeInsets.all(popupPaddingHorizon),
              decoration: BoxDecoration(
                color: context.containerDarkerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: (isDesktop || (isMobile2 && isLandscape))
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.all(popupPadding),
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
                                        Expanded(
                                          child: Text(
                                            "Đơn #${currentOrder!.id.split('-').last}",
                                            textAlign: TextAlign.left,
                                            style: titlePartTextStyle,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 4.h),
                                          decoration: orderStatusBoxDecoration,
                                          child: Text(
                                            orderStatus.label,
                                            style: orderStatusTextStyle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isMobile ? 8.h : 16.h),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.w),
                                        border: Border.all(
                                          color: context
                                              .componentNameTextLighterColor,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(
                                        isMobile ? 8.w : 12.w,
                                      ),
                                      child: SizedBox(
                                        // height: popupContentMaxHeight,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildTableRowDivideTwo(
                                              context: context,
                                              row1: Text(
                                                (currentOrder.type ==
                                                        ModeOfService
                                                            .DineIn.index)
                                                    ? "${Language.table.tr()} ${currentOrder.tableNumberDineIn}"
                                                    : "Hình thức",
                                                style: cartItemTextStyle,
                                              ),
                                              row2: Text(
                                                ModeOfService.values
                                                    .firstWhere(
                                                      (mode) =>
                                                          mode.index ==
                                                          currentOrder.type,
                                                      orElse: () =>
                                                          ModeOfService.DineIn,
                                                    )
                                                    .label,
                                                style: cartItemTextStyle,
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              height: isMobile ? 4.h : 8.h,
                                            ),
                                            _buildTableRowDivideTwo(
                                              context: context,
                                              row1: Text("Thời gian đặt",
                                                  style: cartItemTextStyle),
                                              row2: Text(
                                                DateFormat(
                                                        'EEEE, dd-MM-yyyy h:mm a',
                                                        'vi_VN')
                                                    .format(currentOrder
                                                        .createdDate),
                                                style: cartItemTextStyle,
                                                textAlign: TextAlign.right,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              height: isMobile ? 4.h : 8.h,
                                            ),
                                            _buildTableRowDivideTwo(
                                              context: context,
                                              row1: Text(
                                                "Khách hàng",
                                                style: cartItemTextStyle,
                                              ),
                                              row2: currentOrder
                                                      .customerNameSnapshot
                                                      .isNotNullOrEmpty
                                                  ? Text(
                                                      currentOrder
                                                              .customerNameSnapshot ??
                                                          "",
                                                      style: cartItemTextStyle,
                                                      textAlign:
                                                          TextAlign.right,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : Text(
                                                      "Khách lẻ",
                                                      style: cartItemTextStyle,
                                                      textAlign:
                                                          TextAlign.right,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                            ),
                                            SizedBox(
                                              height: isMobile ? 4.h : 8.h,
                                            ),
                                            _buildTableRowDivideTwo(
                                              context: context,
                                              row1: Text(
                                                "Tạm tính",
                                                style: cartItemTextStyle,
                                              ),
                                              row2: Text(
                                                currentOrder.subTotalAmount
                                                        ?.currency ??
                                                    0.currency,
                                                style: cartItemTextStyle,
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              height: isMobile ? 4.h : 8.h,
                                            ),
                                            _buildTableRowDivideTwo(
                                              context: context,
                                              row1: Text(
                                                "Thuế",
                                                style: cartItemTextStyle,
                                              ),
                                              row2: Text(
                                                currentOrder
                                                        .taxAmount?.currency ??
                                                    0.currency,
                                                style: cartItemTextStyle,
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              height: isMobile ? 4.h : 8.h,
                                            ),
                                            _buildTableRowDivideTwo(
                                              context: context,
                                              row1: Text(
                                                "Giảm giá",
                                                style: cartItemTextStyle,
                                              ),
                                              row2: Text(
                                                (currentOrder.discountAmount
                                                        ?.currency ??
                                                    0.currency),
                                                style: cartItemTextStyle,
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              height: 1.w,
                                              margin: EdgeInsets.symmetric(
                                                vertical:
                                                    isMobile ? 12.h : 16.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: context
                                                    .componentNameTextLighterColor,
                                              ),
                                            ),
                                            _buildTableRowDivideTwo(
                                              context: context,
                                              row1: Text(
                                                "Tổng cộng",
                                                style: cartFinalTotalTextStyle,
                                              ),
                                              row2: Text(
                                                (currentOrder
                                                    .totalAmount.currency),
                                                style: cartFinalTotalTextStyle
                                                    .copyWith(
                                                  color: AppColors.rambutan100,
                                                ),
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if ((currentOrder.type ==
                                                ModeOfService
                                                    .TakeAway.index)) ...[
                                              Container(
                                                height: 1.w,
                                                margin: EdgeInsets.symmetric(
                                                  vertical:
                                                      isMobile ? 12.h : 16.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: context
                                                      .componentNameTextLighterColor,
                                                ),
                                              ),
                                              _buildTableRowDivideTwo(
                                                context: context,
                                                row1: Text(
                                                  "Thời gian lấy",
                                                  style:
                                                      cartFinalTotalTextStyle,
                                                ),
                                                row2: Text(
                                                  (currentOrder.pickupTime !=
                                                          null
                                                      ? DateFormat(
                                                              'EEEE, dd-MM-yyyy h:mm a',
                                                              'vi_VN')
                                                          .format(currentOrder
                                                              .pickupTime!)
                                                      : ''),
                                                  style: cartFinalTotalTextStyle
                                                      .copyWith(
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.all(popupPadding),
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
                                          "Chi tiết đơn hàng",
                                          textAlign: TextAlign.left,
                                          style: titlePartTextStyle,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16.h),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.w),
                                        border: Border.all(
                                          color: context
                                              .componentNameTextLighterColor,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(
                                        isMobile ? 8.w : 12.w,
                                      ),
                                      child: SizedBox(
                                        height: popupContentMaxHeight,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
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
                                                    popupItemHorizonalPadding +
                                                        popupPadding,
                                                vertical:
                                                    popupItemVerticalPadding,
                                              ),
                                              decoration: BoxDecoration(
                                                color: context
                                                    .componentNameTextLighterColor,
                                              ),
                                            ),
                                            Flexible(
                                              fit: FlexFit.loose,
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: Table(
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(4),
                                                    1: FlexColumnWidth(1),
                                                    2: FlexColumnWidth(2),
                                                  },
                                                  children: [
                                                    ..._buildOrderItemRowsDesktop(
                                                      context,
                                                      currentOrder.orderItems,
                                                      cartItemTextStyle,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            right: popupPaddingHorizon + popupPadding,
                            bottom: popupPaddingVertical,
                            left: popupPaddingHorizon,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (currentOrder.isNeedToUpdateInventory)
                                InkWell(
                                  onTap: () async {
                                    try {
                                      await ref
                                          .read(orderViewModelProvider.notifier)
                                          .rollBackInventoryManually(
                                            currentOrder.id,
                                          );
                                    } catch (e) {
                                      handleApiError(
                                        error: e as DioException,
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30.w,
                                      vertical:
                                          (buttonMaxHeight - buttonFontSize) /
                                              2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.rambutan100,
                                      borderRadius: BorderRadius.circular(8.w),
                                      border: Border.all(
                                        color: AppColors.rambutan100,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      "Cập nhật kho thủ công",
                                      style: buttonTextStyle.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.neutral0,
                                      ),
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              if (currentOrder.status ==
                                  OrderStatus.PendingPayment.index)
                                InkWell(
                                  onTap: () async {
                                    final reason =
                                        await _showConfirmCancelOrderDialog(
                                      context,
                                      currentOrder.id,
                                    );
                                    if (reason.isNotNullOrEmpty) {
                                      try {
                                        await ref
                                            .read(
                                                orderViewModelProvider.notifier)
                                            .cancelOrder(
                                              orderId: currentOrder.id,
                                              cancellationReason: reason!,
                                            );
                                        ref
                                            .read(
                                                financialShiftViewModelProvider
                                                    .notifier)
                                            .getTakedTableNumber();
                                      } catch (e) {
                                        handleApiError(
                                          error: e as DioException,
                                        );
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30.w,
                                      vertical:
                                          (buttonMaxHeight - buttonFontSize) /
                                              2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.rambutan100,
                                      borderRadius: BorderRadius.circular(8.w),
                                      border: Border.all(
                                        color: AppColors.rambutan100,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      "Hủy đơn",
                                      style: buttonTextStyle.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.neutral0,
                                      ),
                                    ),
                                  ),
                                ),
                              if (currentOrder.status ==
                                  OrderStatus.Confirmed.index)
                                InkWell(
                                  onTap: () async {
                                    try {
                                      await ref
                                          .read(orderViewModelProvider.notifier)
                                          .completeOrder(
                                              orderId: currentOrder.id);
                                      ref
                                          .read(financialShiftViewModelProvider
                                              .notifier)
                                          .getTakedTableNumber();
                                    } catch (e) {
                                      handleApiError(
                                        error: e as DioException,
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30.w,
                                      vertical:
                                          (buttonMaxHeight - buttonFontSize) /
                                              2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.rambutan100,
                                      borderRadius: BorderRadius.circular(8.w),
                                      border: Border.all(
                                        color: AppColors.rambutan100,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      "Hoàn tất",
                                      style: buttonTextStyle.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.neutral0,
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: popupPaddingVertical,
                              ),
                              InkWell(
                                onTap: () {
                                  // ref
                                  //     .read(orderViewModelProvider.notifier)
                                  //     .removeSelectedOrder();
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30.w,
                                    vertical:
                                        (buttonMaxHeight - buttonFontSize) / 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.containerColor,
                                    borderRadius: BorderRadius.circular(8.w),
                                    border: Border.all(
                                      color:
                                          context.componentNameTextLighterColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    "Đóng",
                                    style: buttonTextStyle.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          context.componentNameTextLighterColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Container(
                      padding: EdgeInsets.all(popupPadding),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Đơn #${currentOrder!.id.split('-').last}",
                                    textAlign: TextAlign.left,
                                    style: titlePartTextStyle,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 4.h),
                                  decoration: orderStatusBoxDecoration,
                                  child: Text(
                                    orderStatus.label,
                                    style: orderStatusTextStyle,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isMobile ? 8.h : 16.h),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.w),
                                border: Border.all(
                                  color: context.componentNameTextLighterColor,
                                ),
                              ),
                              padding: EdgeInsets.all(
                                isMobile ? 8.w : 12.w,
                              ),
                              child: SizedBox(
                                height: popupContentMaxHeight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTableRowDivideTwo(
                                      context: context,
                                      row1: Text(
                                        (currentOrder.type ==
                                                ModeOfService.DineIn.index)
                                            ? "${Language.table.tr()} ${currentOrder.tableNumberDineIn}"
                                            : "Hình thức",
                                        style: cartItemTextStyle,
                                      ),
                                      row2: Text(
                                        ModeOfService.values
                                            .firstWhere(
                                              (mode) =>
                                                  mode.index ==
                                                  currentOrder.type,
                                              orElse: () =>
                                                  ModeOfService.DineIn,
                                            )
                                            .label,
                                        style: cartItemTextStyle,
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(
                                      height: isMobile ? 4.h : 8.h,
                                    ),
                                    _buildTableRowDivideTwo(
                                      context: context,
                                      row1: Text(
                                        "Thời gian đặt",
                                        style: cartItemTextStyle,
                                      ),
                                      row2: Text(
                                        DateFormat('EEEE, dd-MM-yyyy h:mm a',
                                                'vi_VN')
                                            .format(currentOrder.createdDate),
                                        style: cartItemTextStyle,
                                        textAlign: TextAlign.right,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(
                                      height: isMobile ? 4.h : 8.h,
                                    ),
                                    _buildTableRowDivideTwo(
                                      context: context,
                                      row1: Text(
                                        "Khách hàng",
                                        style: cartItemTextStyle,
                                      ),
                                      row2: currentOrder.customerNameSnapshot
                                              .isNotNullOrEmpty
                                          ? Text(
                                              currentOrder
                                                      .customerNameSnapshot ??
                                                  "",
                                              style: cartItemTextStyle,
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : Text(
                                              "Khách lẻ",
                                              style: cartItemTextStyle,
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                    ),
                                    SizedBox(
                                      height: isMobile ? 4.h : 8.h,
                                    ),
                                    _buildTableRowDivideTwo(
                                      context: context,
                                      row1: Text(
                                        "Tạm tính",
                                        style: cartItemTextStyle,
                                      ),
                                      row2: Text(
                                        currentOrder.totalAmount.currency,
                                        style: cartItemTextStyle,
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(
                                      height: isMobile ? 4.h : 8.h,
                                    ),
                                    _buildTableRowDivideTwo(
                                      context: context,
                                      row1: Text(
                                        "Thuế",
                                        style: cartItemTextStyle,
                                      ),
                                      row2: Text(
                                        currentOrder.totalAmount.currency,
                                        style: cartItemTextStyle,
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(
                                      height: isMobile ? 4.h : 8.h,
                                    ),
                                    _buildTableRowDivideTwo(
                                      context: context,
                                      row1: Text(
                                        "Giảm giá",
                                        style: cartItemTextStyle,
                                      ),
                                      row2: Text(
                                        (currentOrder.totalAmount.currency),
                                        style: cartItemTextStyle,
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      height: 1.w,
                                      margin: EdgeInsets.symmetric(
                                        vertical: isMobile ? 12.h : 16.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context
                                            .componentNameTextLighterColor,
                                      ),
                                    ),
                                    _buildTableRowDivideTwo(
                                      context: context,
                                      row1: Text(
                                        "Tổng cộng",
                                        style: cartFinalTotalTextStyle,
                                      ),
                                      row2: Text(
                                        (currentOrder.totalAmount.currency),
                                        style: cartFinalTotalTextStyle.copyWith(
                                          color: AppColors.rambutan100,
                                        ),
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if ((currentOrder.type ==
                                        ModeOfService.TakeAway.index)) ...[
                                      Container(
                                        height: 1.w,
                                        margin: EdgeInsets.symmetric(
                                          vertical: isMobile ? 12.h : 16.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: context
                                              .componentNameTextLighterColor,
                                        ),
                                      ),
                                      _buildTableRowDivideTwo(
                                        context: context,
                                        row1: Text(
                                          "Thời gian lấy",
                                          style: cartFinalTotalTextStyle,
                                        ),
                                        row2: Text(
                                          (currentOrder.pickupTime != null
                                              ? (isMobile
                                                  ? DateFormat(
                                                          'h:mm a', 'vi_VN')
                                                      .format(currentOrder
                                                          .pickupTime!)
                                                  : DateFormat(
                                                          'EEEE, dd-MM-yyyy h:mm a',
                                                          'vi_VN')
                                                      .format(currentOrder
                                                          .pickupTime!))
                                              : ''),
                                          style:
                                              cartFinalTotalTextStyle.copyWith(
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 2,
                                          textAlign: TextAlign.right,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 12.h : 16.h),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Chi tiết đơn hàng",
                                  textAlign: TextAlign.left,
                                  style: titlePartTextStyle,
                                ),
                                SizedBox(height: isMobile ? 8.h : 16.h),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.w),
                                    border: Border.all(
                                      color:
                                          context.componentNameTextLighterColor,
                                    ),
                                  ),
                                  padding: EdgeInsets.all(
                                    isMobile ? 8.w : 12.w,
                                  ),
                                  child: SizedBox(
                                    height: popupContentMaxHeight,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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
                                                popupItemHorizonalPadding +
                                                    popupPadding,
                                            vertical: popupItemVerticalPadding,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context
                                                .componentNameTextLighterColor,
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
                                                ..._buildOrderItemRows(
                                                  context,
                                                  currentOrder.orderItems,
                                                  cartItemTextStyle,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isMobile ? 12.h : 16.h),
                            // Container(
                            //   padding: EdgeInsets.only(
                            //     // right: popupPaddingHorizon,
                            //     bottom: popupPaddingVertical,
                            //     left: popupPaddingHorizon,
                            //   ),
                            //   child: Row(
                            //     crossAxisAlignment: CrossAxisAlignment.end,
                            //     mainAxisAlignment:
                            //         MainAxisAlignment.spaceBetween,
                            //     children: [
                            if (currentOrder.isNeedToUpdateInventory)
                              InkWell(
                                onTap: () async {
                                  try {
                                    await ref
                                        .read(orderViewModelProvider.notifier)
                                        .rollBackInventoryManually(
                                          currentOrder.id,
                                        );
                                  } catch (e) {
                                    handleApiError(
                                      error: e as DioException,
                                    );
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30.w,
                                    vertical:
                                        (buttonMaxHeight - buttonFontSize) / 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.rambutan100,
                                    borderRadius: BorderRadius.circular(8.w),
                                    border: Border.all(
                                      color: AppColors.rambutan100,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Cập nhật kho thủ công",
                                      style: buttonTextStyle.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.neutral0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // const Spacer(),
                            if (currentOrder.status ==
                                OrderStatus.PendingPayment.index)
                              InkWell(
                                onTap: () async {
                                  final reason =
                                      await _showConfirmCancelOrderDialog(
                                    context,
                                    currentOrder.id,
                                  );
                                  if (reason.isNotNullOrEmpty) {
                                    try {
                                      await ref
                                          .read(orderViewModelProvider.notifier)
                                          .cancelOrder(
                                            orderId: currentOrder.id,
                                            cancellationReason: reason!,
                                          );
                                      ref
                                          .read(financialShiftViewModelProvider
                                              .notifier)
                                          .getTakedTableNumber();
                                    } catch (e) {
                                      handleApiError(
                                        error: e as DioException,
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30.w,
                                    vertical:
                                        (buttonMaxHeight - buttonFontSize) / 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.rambutan100,
                                    borderRadius: BorderRadius.circular(8.w),
                                    border: Border.all(
                                      color: AppColors.rambutan100,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Hủy đơn",
                                      style: buttonTextStyle.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.neutral0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (currentOrder.status ==
                                OrderStatus.PendingPayment.index)
                              SizedBox(
                                height: 8.h,
                              ),
                            if (currentOrder.status ==
                                OrderStatus.Confirmed.index)
                              InkWell(
                                onTap: () async {
                                  try {
                                    await ref
                                        .read(orderViewModelProvider.notifier)
                                        .completeOrder(
                                            orderId: currentOrder.id);
                                    ref
                                        .read(financialShiftViewModelProvider
                                            .notifier)
                                        .getTakedTableNumber();
                                  } catch (e) {
                                    handleApiError(
                                      error: e as DioException,
                                    );
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30.w,
                                    vertical:
                                        (buttonMaxHeight - buttonFontSize) / 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.rambutan100,
                                    borderRadius: BorderRadius.circular(8.w),
                                    border: Border.all(
                                      color: AppColors.rambutan100,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Hoàn tất",
                                      style: buttonTextStyle.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.neutral0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (currentOrder.status ==
                                OrderStatus.Confirmed.index)
                              SizedBox(
                                height: 8.h,
                              ),
                            InkWell(
                              onTap: () {
                                // ref
                                //     .read(orderViewModelProvider.notifier)
                                //     .removeSelectedOrder();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30.w,
                                  vertical:
                                      (buttonMaxHeight - buttonFontSize) / 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.containerColor,
                                  borderRadius: BorderRadius.circular(8.w),
                                  border: Border.all(
                                    color:
                                        context.componentNameTextLighterColor,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Đóng",
                                    style: buttonTextStyle.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          context.componentNameTextLighterColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //     ],
                      //   ),
                      // ),
                    ),
            ),
          ),
          if (orderViewModel.value?.isSelectedOrderLoading ?? false)
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
    );
  }

  List<TableRow> _buildOrderItemRows(
    BuildContext context,
    List<OrderItem> orderItems,
    TextStyle cartItemTextStyle,
  ) {
    final List<TableRow> rows = [];
    final mainProducts = orderItems.toList();
    for (var mainProduct in mainProducts) {
      rows.add(
        _buildTableRowDivideThree(
          context,
          Text(
            mainProduct.productVariantNameSnapshot,
            style: cartItemTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.left,
          ),
          Text(
            "x${mainProduct.quantity}",
            style: cartItemTextStyle,
            textAlign: TextAlign.center,
          ),
          Text(
            (mainProduct.unitPriceSnapshot * mainProduct.quantity).currency,
            style: cartItemTextStyle,
            textAlign: TextAlign.right,
          ),
        ),
      );

      if (mainProduct.orderItemExtras.isNotEmpty) {
        for (var extraItem in mainProduct.orderItemExtras) {
          rows.add(
            _buildTableRowDivideThree(
              context,
              Text(
                "+ ${extraItem.productVariantNameSnapshot}",
                style: context.labelSmall.copyWith(
                  color: context.onSurfaceColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                ),
                textAlign: TextAlign.left,
              ),
              Text(
                "x${extraItem.quantity.toString()}",
                style: context.labelSmall.copyWith(
                  color: context.onSurfaceColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                (extraItem.unitPriceSnapshot * extraItem.quantity).currency,
                style: context.labelSmall.copyWith(
                  color: context.onSurfaceColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
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

  /// Helper method for desktop layout with selected options support
  List<TableRow> _buildOrderItemRowsDesktop(
    BuildContext context,
    List<OrderItem> orderItems,
    TextStyle cartItemTextStyle,
  ) {
    final List<TableRow> rows = [];
    final mainProducts = orderItems.toList();
    for (var mainProduct in mainProducts) {
      rows.add(
        _buildTableRowDivideThree(
          context,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.h,
            children: [
              Text(
                mainProduct.productVariantNameSnapshot,
                style: cartItemTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.left,
              ),
              if (mainProduct.orderItemSelectedOptions.isNotEmpty)
                ...mainProduct.orderItemSelectedOptions.map((option) {
                  return Text(
                    '• ${option.modifierOptionSnapshot}',
                    style: context.labelSmall.copyWith(
                      color: context.onSurfaceColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
            ],
          ),
          Text(
            "x${mainProduct.quantity}",
            style: cartItemTextStyle,
            textAlign: TextAlign.center,
          ),
          Text(
            mainProduct.totalPriceBeforeItemDiscount.currency,
            style: cartItemTextStyle,
            textAlign: TextAlign.right,
          ),
        ),
      );

      if (mainProduct.orderItemExtras.isNotEmpty) {
        for (var extraItem in mainProduct.orderItemExtras) {
          rows.add(
            _buildTableRowDivideThree(
              context,
              Text(
                "+ ${extraItem.productVariantNameSnapshot}",
                style: context.labelSmall.copyWith(
                  color: context.onSurfaceColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                ),
                textAlign: TextAlign.left,
              ),
              Text(
                "x${extraItem.quantity.toString()}",
                style: context.labelSmall.copyWith(
                  color: context.onSurfaceColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                (extraItem.unitPriceSnapshot * extraItem.quantity).currency,
                style: context.labelSmall.copyWith(
                  color: context.onSurfaceColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 8.w,
        children: [
          row1 ?? Container(),
          Expanded(child: row2 ?? Container()),
        ],
      ),
    ),
  );
}

TableRow _buildTableRowDivideThree(
  BuildContext context,
  Widget row1,
  Text row2,
  Text row3, {
  bool hasTopBorder = false,
  bool hasBottomBorder = false,
  Color? borderColor,
  bool isExtraItem = false,
}) {
  final double rowPaddingHeight = isExtraItem ? 0 : 8.w;
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
