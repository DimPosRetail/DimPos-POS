import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/date_time_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/common/ui/widgets/confirm_financial_shift_dialog.dart';
import 'package:dimpos_store/features/common/ui/widgets/date_time_badge.dart';
import 'package:dimpos_store/features/notification/models/notification_message.dart';
import 'package:dimpos_store/features/notification/ui/state/notification_state.dart';
import 'package:dimpos_store/features/notification/ui/view_models/notification_hub_view_model.dart';
import 'package:dimpos_store/features/notification/ui/view_models/notification_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/financial_shift_view_model.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Header extends ConsumerStatefulWidget {
  final bool isMobile;
  const Header({
    super.key,
    required this.isMobile,
  });

  @override
  ConsumerState<Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<Header> {
  final OverlayPortalController _tooltipController = OverlayPortalController();
  final GlobalKey _notificationKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final unReadCount = ref
            .watch(notificationHubViewModelProvider)
            .value
            ?.unReadNotifications ??
        0;
    final isMobile = SizeConfig.getDeviceType() == DeviceType.mobile ||
        SizeConfig.getDeviceType() == DeviceType.tablet;
    final isDesktop = SizeConfig.getDeviceType() == DeviceType.desktop;
    final isLandscape = SizeConfig.isLandscape();
    final isShiftOpen =
        ref.watch(financialShiftViewModelProvider).value?.isShiftOpen;
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (isDesktop || (isMobile && isLandscape)) ...[
                  DateTimeBadge(
                    dateTime: (isMobile && isLandscape)
                        ? DateTime.now().formatDateInShort
                        : DateTime.now().formatDate,
                    icon: Assets.calendar,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      '-',
                      style:
                          TextStyle(fontSize: 20.sp, color: context.subColor),
                    ),
                  ),
                  DateTimeBadge(
                    dateTime: DateTime.now().formatTime,
                    icon: Assets.clock,
                  ),
                ],
                if (!widget.isMobile)
                  SizedBox(
                    width: 8.w,
                  ),
              ],
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 10.w,
              children: [
                if (isShiftOpen == true)
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmFinancialShiftDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rambutan100,
                      foregroundColor: context.surfaceColor,
                      padding: EdgeInsets.symmetric(
                        vertical: 16.h,
                        horizontal: 20.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                    ),
                    child: Text(
                      'Đóng ca',
                      style: TextStyle(
                        fontSize: isMobile ? 14.sp : 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                OverlayPortal(
                  controller: _tooltipController,
                  overlayChildBuilder: (BuildContext context) {
                    return _buildNotificationPanel(isMobile);
                  },
                  child: InkWell(
                    key: _notificationKey,
                    onTap: () async {
                      if (!_tooltipController.isShowing) {
                        ref
                            .read(notificationViewModelProvider.notifier)
                            .fetchNotifications();
                        _tooltipController.show();
                      } else {
                        // Hide overlay
                        _tooltipController.hide();
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset(
                          Assets.notification,
                          width: 32.w,
                          color: context.onSurfaceColor,
                        ),
                        if (unReadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 16.w,
                              height: 16.h,
                              decoration: BoxDecoration(
                                color: context.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  unReadCount > 9 ? '9+' : '$unReadCount',
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    color: context.surfaceColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNotificationPanel(bool isMobile) {
    return Stack(
      children: [
        // Invisible overlay to detect clicks outside
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
        // Notification panel
        Positioned(
          top: _getNotificationPosition().dy + 30.h,
          right: MediaQuery.of(context).size.width -
              _getNotificationPosition().dx -
              20.w,
          child: GestureDetector(
            onTap: () {
              // Prevent closing when clicking inside the panel
            },
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8.w),
              color: Colors.white,
              shadowColor: Colors.black26,
              child: Container(
                width: isMobile ? 250.w : 350.w,
                constraints: BoxConstraints(maxHeight: 400.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.w),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final notificationState =
                        ref.watch(notificationViewModelProvider);
                    final notificationViewModel =
                        ref.read(notificationViewModelProvider.notifier);
                    final notificationHubViewModel =
                        ref.read(notificationHubViewModelProvider.notifier);
                    final unReadCount = ref
                            .watch(notificationHubViewModelProvider)
                            .value
                            ?.unReadNotifications ??
                        0;

                    return notificationState.when(
                      loading: () => _buildLoadingState(),
                      error: (error, stack) =>
                          _buildErrorState(error, notificationViewModel),
                      data: (state) => _buildNotificationContent(
                        state,
                        notificationViewModel,
                        notificationHubViewModel,
                        unReadCount,
                        isMobile,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the loading state when notifications are being fetched for the first time
  Widget _buildLoadingState() {
    return Container(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2.w,
              color: context.primaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Đang tải thông báo...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the error state when fetching notifications fails
  Widget _buildErrorState(Object error, NotificationViewModel viewModel) {
    return Container(
      height: 200.h,
      padding: EdgeInsets.all(20.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.w,
              color: Colors.red.shade300,
            ),
            SizedBox(height: 16.h),
            Text(
              'Không thể tải thông báo',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Vui lòng thử lại',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => viewModel.fetchNotifications(),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              ),
              child: Text(
                'Thử lại',
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main notification content with the list and pagination
  Widget _buildNotificationContent(
    NotificationState state,
    NotificationViewModel viewModel,
    NotificationHubViewModel notificationHubViewModel,
    int unReadCount,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with notification count and delete all action
        _buildNotificationHeader(
            state, viewModel, notificationHubViewModel, unReadCount),

        // Notification list with scroll detection for pagination
        Flexible(
          child: state.notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationList(state, viewModel, isMobile),
        ),

        // Footer with mark all as read button
        if (state.notifications.isNotEmpty)
          _buildNotificationFooter(viewModel, notificationHubViewModel),
      ],
    );
  }

  /// Builds the notification panel header with count and actions
  Widget _buildNotificationHeader(
    NotificationState state,
    NotificationViewModel viewModel,
    NotificationHubViewModel notificationHubViewModel,
    int unReadCount,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Thông báo (${state.totalNotifications})',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          InkWell(
            onTap: state.notifications.isNotEmpty
                ? () {
                    viewModel.deleteAllNotifications();
                    notificationHubViewModel.setUnreadNotifications(0);
                  }
                : null,
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 16.w,
                  color: state.notifications.isNotEmpty
                      ? Colors.grey.shade600
                      : Colors.grey.shade400,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Xóa tất cả',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: state.notifications.isNotEmpty
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the scrollable notification list with pagination support
  Widget _buildNotificationList(
    NotificationState state,
    NotificationViewModel viewModel,
    bool isMobile,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Detect when user reaches the bottom of the list
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 50.h &&
            !state.isLoadingMore &&
            state.hasMoreData) {
          // Load more notifications when near the bottom
          viewModel.loadMoreNotifications();
        }
        return false; // Allow the notification to continue bubbling up
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Display each notification
            ...state.notifications.map((notification) {
              return _buildNotificationItem(notification, isMobile);
            }),

            // Show loading indicator at bottom when loading more
            if (state.isLoadingMore)
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: context.primaryColor,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Đang tải thêm...',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

            // Show "no more data" message when all notifications are loaded
            if (!state.hasMoreData && state.notifications.length > 4)
              Container(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'Đã hiển thị tất cả thông báo',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds an individual notification item
  Widget _buildNotificationItem(
      NotificationMessage notification, bool isMobile) {
    // Determine notification color and icon based on type and read status
    final isError =
        notification.notification.type == 1; // Assuming 1 = error, 0 = info
    final notificationColor = isError ? Colors.red : context.primaryColor;
    final backgroundColor =
        notification.isRead ? Colors.grey.shade50 : Colors.white;

    return Container(
      padding: EdgeInsets.all(16.w),
      color: backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored indicator line
          Container(
            width: 4.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: notificationColor,
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
          SizedBox(width: 12.w),

          // Notification content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification icon
                    Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: notificationColor, width: 2),
                      ),
                      child: Icon(
                        isError ? Icons.error_outline : Icons.info_outline,
                        size: 14.w,
                        color: notificationColor,
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Notification message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.notification.message,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: notification.isRead
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                              height: 1.4,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Text(
                                isError ? 'Lỗi' : 'Thông tin',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                ' • ',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                _formatNotificationTime(
                                    notification.notification.createdDate),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the empty state when no notifications are available
  Widget _buildEmptyState() {
    return Container(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 48.w,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'Không có thông báo',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tất cả thông báo sẽ hiển thị tại đây',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the footer with mark all as read button
  Widget _buildNotificationFooter(NotificationViewModel viewModel,
      NotificationHubViewModel notificationHubViewModel) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            viewModel.markAllAsRead();
            notificationHubViewModel.setUnreadNotifications(0);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            foregroundColor: Colors.black87,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.w),
            ),
          ),
          child: Text(
            'Đánh dấu tất cả đã đọc',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Helper function to format notification time in a user-friendly way
  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      // Format as specific date for older notifications
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Offset _getNotificationPosition() {
    final RenderBox? renderBox =
        _notificationKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.localToGlobal(Offset.zero);
    }
    return Offset.zero;
  }
}

void _showConfirmFinancialShiftDialog(BuildContext context) async {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return const ConfirmFinancialShiftDialog();
    },
  );
}
