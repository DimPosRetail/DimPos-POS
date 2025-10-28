import 'package:dimpos_store/constants/language.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/enums/mode_of_service.dart';
import 'package:dimpos_store/enums/order_status.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/currency_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/extensions/string_extension.dart';
import 'package:dimpos_store/features/order/models/order.dart';
import 'package:dimpos_store/features/order/models/order_item.dart';
import 'package:dimpos_store/features/order/ui/view_models/order_view_model.dart';
import 'package:dimpos_store/features/order/ui/widgets/confirm_cancel_order_dialog.dart';
import 'package:dimpos_store/features/order/ui/widgets/order_detail_dialog.dart';
import 'package:dimpos_store/features/product/ui/view_models/financial_shift_view_model.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/exception.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderListView extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const OrderListView({
    super.key,
    required this.scrollController,
  });

  @override
  ConsumerState<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends ConsumerState<OrderListView> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    widget.scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentPosition = widget.scrollController.position.pixels;
    final maxScroll = widget.scrollController.position.maxScrollExtent;

    const threshold = 200.0;

    if (currentPosition >= maxScroll - threshold) {
      final orderState = ref.read(orderViewModelProvider).value;

      if (orderState != null &&
          !orderState.isLoadingMore &&
          orderState.hasMoreData &&
          orderState.errorMessage.isEmpty) {
        ref.read(orderViewModelProvider.notifier).loadMoreOrders();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final bool isLandscape = SizeConfig.isLandscape();
    double desiredHeight;
    int crossAxisCount;

    switch (SizeConfig.getDeviceType()) {
      case DeviceType.mobile:
        crossAxisCount = 1;
        desiredHeight = 240.h;
        break;
      case DeviceType.tablet:
        crossAxisCount = isLandscape ? 3 : 2;
        desiredHeight = isLandscape ? 320.h : 300.h;
        break;
      default:
        crossAxisCount = 4;
        desiredHeight = 420.h;
        break;
    }

    // Calculate grid dimensions
    final horizontalSpacing = 5.w * (crossAxisCount - 1);
    final availableWidth = SizeConfig.screenWidth - horizontalSpacing - (16.w);
    final itemWidth = availableWidth / crossAxisCount;
    final childAspectRatio = (itemWidth / desiredHeight);

    final orderViewModel = ref.watch(orderViewModelProvider);
    final allOrders = orderViewModel.value?.allOrders ?? [];
    final isLoadingMore = orderViewModel.value?.isLoadingMore ?? false;
    final hasMoreData = orderViewModel.value?.hasMoreData ?? false;
    final isLoading = orderViewModel.isLoading;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                ),
                padding: EdgeInsets.only(top: 0.h, bottom: 10.h),
                itemCount: isLoading
                    ? crossAxisCount * 2
                    : allOrders.length, // Show skeleton items when loading
                itemBuilder: (context, gridIndex) {
                  if (isLoading) {
                    // Show skeleton loading cards
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = constraints.maxWidth;
                        return _buildOrderCardSkeleton(context, itemWidth);
                      },
                    );
                  }

                  final order = allOrders[gridIndex];
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = constraints.maxWidth;
                      return _buildOrderCard(
                        context,
                        ref,
                        itemWidth,
                        ordinalNumber: gridIndex + 1,
                        order: order,
                        onRemoveTap: () async {
                          final reason = await _showConfirmCancelOrderDialog(
                            context,
                            order.id,
                          );
                          if (reason.isNotNullOrEmpty) {
                            try {
                              await ref
                                  .read(orderViewModelProvider.notifier)
                                  .cancelOrder(
                                    orderId: order.id,
                                    cancellationReason: reason!,
                                  );
                              ref
                                  .read(
                                      financialShiftViewModelProvider.notifier)
                                  .getTakedTableNumber();
                            } catch (e) {
                              handleApiError(
                                error: e as DioException,
                              );
                            }
                          }
                        },
                        onViewTap: () {
                          if (order.id.isNotNullOrEmpty) {
                            ref
                                .read(orderViewModelProvider.notifier)
                                .setSelectedOrder(order);
                            _showOrderDetailDialog(context, order.id);
                          }
                        },
                        isEnabled:
                            order.status != OrderStatus.Completed.index &&
                                order.status != OrderStatus.Cancelled.index,
                      );
                    },
                  );
                },
              );
            }

            // Build the loading indicator at the bottom when loading more data
            if (index == 1 && isLoadingMore) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.rambutan100,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Đang tải thêm đơn hàng...',
                        style: context.titleMedium.copyWith(
                          color: context.componentNameTextColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (index == 1 && !hasMoreData && allOrders.isNotEmpty) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Text(
                    'Đã hiển thị tất cả đơn hàng',
                    style: context.titleMedium.copyWith(
                      color: context.componentNameTextDarkColor,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
          childCount: 2, // Grid + loading indicator/end message
        ),
      ),
    );
  }

  Widget _buildOrderCardSkeleton(BuildContext context, double itemWidth) {
    SizeConfig.init(context);
    bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
    final cardPaddingWidth = 16.w;
    final cardPaddingHeight = 16.h;
    final linePaddingHeight = 8.h;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: cardPaddingHeight,
        horizontal: cardPaddingWidth,
      ),
      decoration: BoxDecoration(
        color: context.containerLighterColor,
        boxShadow: [
          BoxShadow(
            color: context.boxShadow.color,
            offset: context.boxShadow.offset,
            blurRadius: context.boxShadow.blurRadius,
          ),
        ],
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and time skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSkeletonBox(80.w, 12.h),
              _buildSkeletonBox(60.w, 12.h),
            ],
          ),
          SizedBox(height: 8.h),

          // Order number and status skeleton
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order number badge skeleton
                    _buildSkeletonBox(50.w, 50.w, isCircular: true),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4.h,
                        children: [
                          _buildSkeletonBox(80.w, 18.h),
                          _buildSkeletonBox(60.w, 12.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 6.h,
                children: [
                  _buildSkeletonBox(60.w, 20.h),
                  _buildSkeletonBox(50.w, 12.h),
                ],
              ),
            ],
          ),

          // Table items skeleton (only for non-mobile)
          if (!isMobile) ...[
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: linePaddingHeight),
              height: 1.h,
              color: AppColors.neutral20,
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // Item rows skeleton
                  for (int i = 0; i < 3; i++) ...[
                    Row(
                      children: [
                        Expanded(
                            flex: 4,
                            child: _buildSkeletonBox(double.infinity, 12.h)),
                        SizedBox(width: 8.w),
                        Expanded(
                            flex: 1,
                            child: _buildSkeletonBox(double.infinity, 12.h)),
                        SizedBox(width: 8.w),
                        Expanded(
                            flex: 2,
                            child: _buildSkeletonBox(double.infinity, 12.h)),
                      ],
                    ),
                    if (i < 2) SizedBox(height: 4.h),
                  ],
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: linePaddingHeight),
              height: 1.h,
              color: AppColors.neutral20,
            ),
          ],

          if (isMobile) SizedBox(height: 8.h),

          // Total amount skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSkeletonBox(60.w, 18.h),
              _buildSkeletonBox(80.w, 18.h),
            ],
          ),
          SizedBox(height: 12.h),

          // Buttons skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 8.w,
            children: [
              _buildSkeletonBox(48.w, 48.h),
              Expanded(child: _buildSkeletonBox(double.infinity, 48.h)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonBox(double width, double height,
      {bool isCircular = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.componentNameTextLighterColor.withOpacity(0.2),
            context.componentNameTextLighterColor.withOpacity(0.4),
            context.componentNameTextLighterColor.withOpacity(0.2),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: isCircular
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(4.w),
      ),
    );
  }
}

Widget _buildOrderCard(
  BuildContext context,
  WidgetRef ref,
  double itemWidth, {
  required int ordinalNumber,
  required Order order,
  required Function() onRemoveTap,
  required Function() onViewTap,
  required bool isEnabled,
}) {
  SizeConfig.init(context);
  bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
  final orderStatus = OrderStatus.values.firstWhere(
    (status) => status.index == order.status,
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
  final modeOfService = ModeOfService.values.firstWhere(
    (mode) => mode.index == order.type,
    orElse: () => ModeOfService.DineIn,
  );
  final orderAt = order.createdDate;
  final orderDate = DateFormat('EEEE, dd-MM-yyyy', 'vi_VN').format(orderAt);
  final orderTime = DateFormat('h:mm a').format(orderAt);
  final cardPaddingWidth = 16.w;
  final cardPaddingHeight = 16.h;
  final dateTextStyle = context.titleMedium.copyWith(
    color: context.componentNameTextDarkColor,
    fontWeight: FontWeight.w500,
    fontSize: 12.sp,
  );
  final orderDinalnumberTextStyle = context.titleMedium.copyWith(
    color: AppColors.neutral0,
    fontWeight: FontWeight.bold,
    fontSize: 20.sp,
  );
  final orderNumberTextStype = context.titleMedium.copyWith(
    color: context.componentNameTextColor,
    fontWeight: FontWeight.bold,
    fontSize: 18.sp,
  );
  final tableNumberTextStyle = context.titleMedium.copyWith(
    color: AppColors.neutral100,
    fontWeight: FontWeight.w400,
    fontSize: 12.sp,
  );
  final serviceModeTextStyle = context.titleMedium.copyWith(
    color: context.componentNameTextDarkColor,
    fontWeight: FontWeight.w400,
    fontSize: 12.sp,
  );
  final orderStatusTextStyle = context.titleMedium.copyWith(
    color: statusColor,
    fontWeight: FontWeight.w400,
    fontSize: 12.sp,
  );
  final orderStatusBoxDecoration = BoxDecoration(
    color: statusColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(4.w),
  );
  final orderItemTextStyle = context.titleMedium.copyWith(
    color: context.componentNameTextDarkColor,
    fontWeight: FontWeight.w600,
    fontSize: 12.sp,
  );
  final orderFinalPriceTextStyle = context.titleMedium.copyWith(
    color: context.componentNameTextDarkColor,
    fontWeight: FontWeight.w600,
    fontSize: 18.sp,
  );
  final linePaddingHeight = 8.h;
  return Container(
    padding: EdgeInsets.symmetric(
      vertical: cardPaddingHeight,
      horizontal: cardPaddingWidth,
    ),
    decoration: BoxDecoration(
      color: context.containerLighterColor,
      boxShadow: [
        BoxShadow(
          color: context.boxShadow.color,
          offset: context.boxShadow.offset,
          blurRadius: context.boxShadow.blurRadius,
        ),
      ],
      borderRadius: BorderRadius.circular(8.w),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(orderDate, style: dateTextStyle),
            Text(orderTime, style: dateTextStyle),
          ],
        ),
        SizedBox(height: 4.h),
        if (order.customerNameSnapshot.isNotNullOrEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Khách hàng", style: dateTextStyle),
              Text(order.customerNameSnapshot ?? "", style: dateTextStyle),
            ],
          ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: Center(
                          child: Text(
                            ordinalNumber.toString().padLeft(2, '0'),
                            style: orderDinalnumberTextStyle,
                          ),
                        ),
                      ),
                      if (order.isNeedToUpdateInventory)
                        Positioned.fill(
                          child: Container(
                            color: context.containerColor.withOpacity(0.6),
                            child: Center(
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.rambutan100,
                                size: 20.w,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 4.h,
                      children: [
                        Text(
                          '#${order.id.split('-').last}',
                          style: orderNumberTextStype,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),

                        // SizedBox(height: 6.h),
                        if (order.tableNumberDineIn != null &&
                            modeOfService == ModeOfService.DineIn)
                          Text(
                            '${Language.table.tr()} ${order.tableNumberDineIn}',
                            style: tableNumberTextStyle,
                          ),
                        if (order.isNeedToUpdateInventory)
                          Text(
                            "Cần cập nhật kho thủ công!",
                            style: tableNumberTextStyle.copyWith(
                                color: AppColors.rambutan100,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 6.h,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: orderStatusBoxDecoration,
                  child: Text(
                    orderStatus.label,
                    style: orderStatusTextStyle,
                  ),
                ),
                Text(
                  modeOfService.label,
                  style: serviceModeTextStyle,
                ),
              ],
            ),
          ],
        ),
        // Divider
        if (!isMobile) ...[
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: linePaddingHeight),
            height: 1.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.w),
              color: AppColors.neutral20,
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
                  ..._buildOrderItemRowsForCard(
                    context,
                    order.orderItems,
                    orderItemTextStyle,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: linePaddingHeight),
            height: 1.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.w),
              color: AppColors.neutral20,
            ),
          ),
        ],
        if (isMobile) SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tổng cộng',
              style: orderFinalPriceTextStyle,
            ),
            Text(
              '${order.totalAmount.currency}',
              style: orderFinalPriceTextStyle.copyWith(
                color: AppColors.rambutan100,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        buildTwoButtonRow(
          context,
          itemWidth,
          cardPaddingWidth,
          firstButtonIcon: Icon(
            Icons.delete,
            color: isEnabled ? AppColors.rambutan100 : context.disabledColor,
            size: 24.w,
          ),
          firstButtonDecoration: BoxDecoration(
            color: isEnabled
                ? context.containerLighterColor
                : context.containerDarkColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10.w),
            border: Border.all(
              color: isEnabled ? AppColors.rambutan100 : context.disabledColor,
              width: 1.w,
            ),
          ),
          secondButtonText: Text(
            'Xem chi tiết',
            style: context.titleMedium.copyWith(
              color: AppColors.neutral0,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          secondButtonDecoration: BoxDecoration(
            color: AppColors.rambutan100,
            borderRadius: BorderRadius.circular(8.w),
          ),
          onFirstButtonTap: onRemoveTap,
          onSecondButtonTap: onViewTap,
          isEnabled: isEnabled,
          canCancelOrder: order.status != OrderStatus.Completed.index &&
              order.status != OrderStatus.Cancelled.index &&
              order.status != OrderStatus.Confirmed.index,
        ),
      ],
    ),
  );
}

List<TableRow> _buildOrderItemRowsForCard(
  BuildContext context,
  List<OrderItem> orderItems,
  TextStyle orderItemTextStyle,
) {
  final List<TableRow> rows = [];
  final mainProducts = orderItems.toList();

  for (var mainProduct in mainProducts) {
    rows.add(
      _buildTableRowDivideThree(
        context,
        Text(
          mainProduct.productVariantNameSnapshot,
          style: orderItemTextStyle,
          textAlign: TextAlign.left,
        ),
        Text(
          "x${mainProduct.quantity.toString()}",
          style: orderItemTextStyle,
          textAlign: TextAlign.center,
        ),
        Text(
          mainProduct.totalPriceBeforeItemDiscount.currency,
          style: orderItemTextStyle,
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
              style: orderItemTextStyle.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: context.onSurfaceColor,
              ),
              textAlign: TextAlign.left,
            ),
            Text(
              "x${extraItem.quantity.toString()}",
              style: orderItemTextStyle.copyWith(
                fontSize: 12.sp,
                color: context.onSurfaceColor,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              (extraItem.unitPriceSnapshot * extraItem.quantity).currency,
              style: orderItemTextStyle.copyWith(
                fontSize: 12.sp,
                color: context.onSurfaceColor,
                fontWeight: FontWeight.w400,
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

TableRow _buildTableRowDivideThree(
  BuildContext context,
  Text row1,
  Text row2,
  Text row3, {
  bool hasTopBorder = false,
  bool hasBottomBorder = false,
  bool isExtraItem = false,
}) {
  // final fontSize = 12.sp;
  final double rowPaddingHeight = isExtraItem ? 0 : 4.w;
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
  required bool canCancelOrder,
}) {
  final double firstButtonPadding = 12.w;
  final double componentSpacing = 8.w;
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    spacing: componentSpacing,
    children: [
      if (canCancelOrder)
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
      Expanded(
        child: InkWell(
          onTap: onSecondButtonTap,
          child: Container(
            padding: EdgeInsets.all(12.w),
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
      ),
    ],
  );
}

void _showOrderDetailDialog(BuildContext context, String orderId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return OrderDetailDialog(
        orderId: orderId,
      );
    },
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
