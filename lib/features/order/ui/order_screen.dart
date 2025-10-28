import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/common/ui/widgets/custom_search_filter_bar.dart';
import 'package:dimpos_store/features/common/ui/widgets/header.dart';
import 'package:dimpos_store/features/order/ui/view_models/order_view_model.dart';
import 'package:dimpos_store/features/order/ui/widgets/date_range_picker_dialog.dart'
    as custom_date_picker;
import 'package:dimpos_store/features/order/ui/widgets/order_list_view.dart';
import 'package:dimpos_store/features/order/ui/widgets/order_status_item_list.dart';
import 'package:dimpos_store/features/product/ui/widgets/sticky_header.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  // bool _dialogShown = false;
  // late final ProviderSubscription<AsyncValue<bool>> _subscription;
  final ScrollController _scrollController = ScrollController();

  // Date range state
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;

  void _showDateRangePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => custom_date_picker.DateRangePickerDialog(
        initialFromDate: _selectedFromDate,
        initialToDate: _selectedToDate,
        onDateRangeSelected: (fromDate, toDate) {
          setState(() {
            _selectedFromDate = fromDate;
            _selectedToDate = toDate;
          });

          // Update the date range in the view model and refresh orders
          ref
              .read(orderViewModelProvider.notifier)
              .setDateRange(fromDate, toDate);
          ref.read(orderViewModelProvider.notifier).refreshOrders();
        },
      ),
    );
  }

  // void _handleConnectivityChange(BuildContext context, bool isOnline) {
  //   double sizePercentage = 0.4;
  //   final screenHeight = MediaQuery.of(context).size.height;
  //   final imageSizeWidth = 200.w;

  //   final image = Image.asset(
  //     Assets.loadingError,
  //     width: imageSizeWidth,
  //     fit: BoxFit.cover,
  //   );
  //   if (!isOnline && !_dialogShown) {
  //     _dialogShown = true;
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (_) => AlertDialog(
  //         backgroundColor: context.containerColor,
  //         content: Container(
  //           width: sizePercentage * screenHeight,
  //           height: sizePercentage * screenHeight,
  //           decoration: BoxDecoration(
  //             color: context.containerColor,
  //           ),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               Text(
  //                 "Mất kết nối",
  //                 textAlign: TextAlign.center,
  //                 style: context.titleLarge.copyWith(
  //                   color: context.componentNameTextColor,
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: 12.h,
  //               ),
  //               image,
  //               SizedBox(
  //                 height: 12.h,
  //               ),
  //               Text(
  //                 "Bạn đang offline. Vui lòng kiểm tra kết nối mạng.",
  //                 textAlign: TextAlign.center,
  //                 style: context.titleMedium.copyWith(
  //                   color: context.componentNameTextColor,
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   } else if (isOnline && _dialogShown) {
  //     Navigator.of(context, rootNavigator: true).pop();
  //     _dialogShown = false;
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();

  //   // 3. Lắng nghe trạng thái mạng
  //   _subscription = ref.listenManual<AsyncValue<bool>>(
  //     isOnlineProvider,
  //     (previous, next) {
  //       next.whenData((isOnline) {
  //         _handleConnectivityChange(context, isOnline);
  //       });
  //     },
  //   );
  // }

  // @override
  // void dispose() {
  //   _subscription.close();
  //   // _scrollController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
    final isDesktop = SizeConfig.getDeviceType() == DeviceType.desktop;
    // final isOnlineAsync = ref.watch(isOnlineProvider);
    // if (isOnlineAsync.isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    // if (isOnlineAsync.hasError || isOnlineAsync.value == null) {
    //   return ShowErrorDialog(
    //     errorMessage: "Đã có mạng xảy ra",
    //   );
    // }
    return Stack(
      children: [
        Positioned.fill(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      // Header
                      Header(
                        isMobile: isMobile,
                      ),
                      // Title
                      Padding(
                        padding: EdgeInsets.only(top: 30.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Đơn hàng",
                              style: context.titleMedium.copyWith(
                                fontSize: 24.sp,
                                color: context.onSurfaceColor,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _showDateRangePickerDialog();
                              },
                              child: Icon(
                                Icons.more_horiz,
                                color: context.onSurfaceColor,
                                size: 20.w,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyHeaderDelegate(
                  minHeight: isDesktop
                      ? 140.h
                      : 115.h, // Minimum height for shrunk mode
                  maxHeight: isDesktop
                      ? 140.h
                      : 115.h, // Maximum height for expanded mode
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isShrunk = constraints.maxHeight <= 180.h;
                      return Container(
                        color: context.containerColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // if (!isDesktop)
                            //   Container(
                            //     padding: EdgeInsets.symmetric(
                            //       horizontal: 20.w,
                            //       vertical: 0.w,
                            //     ),
                            //     margin: EdgeInsets.only(top: 10.h),
                            //     child: const CustomSearchFilterBar(
                            //       isMenuScreen: false,
                            //     ),
                            //   ),
                            // Category list with flexible height
                            SizedBox(
                              height: isShrunk ? 65.h : 150.h,
                              child: OrderStatusItemList(),
                            ),
                            // Search bar with consistent height
                            // if (isDesktop)
                            //   Container(
                            //     padding: EdgeInsets.symmetric(
                            //       horizontal: 20.w,
                            //       vertical: 0.w,
                            //     ),
                            //     margin: EdgeInsets.only(top: 10.h),
                            //     child: const CustomSearchFilterBar(
                            //       isMenuScreen: false,
                            //     ),
                            //   ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              OrderListView(
                scrollController: _scrollController,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
