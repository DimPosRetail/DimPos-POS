import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/enums/order_status.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/common/models/display_item.dart';
import 'package:dimpos_store/features/order/ui/view_models/order_view_model.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderStatusItemList extends ConsumerWidget {
  const OrderStatusItemList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    bool isDesktop = SizeConfig.getDeviceType() == DeviceType.desktop;
    final textStyle = context.titleMedium.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: context.componentNameTextColor,
    );
    final orderStatusDisplayItems = OrderStatus.values.map((status) {
      return DisplayItem(value: status.index, display: status.label);
    }).toList();
    orderStatusDisplayItems.insert(
      0,
      DisplayItem(value: null, display: "Tất cả"),
    );
    return LayoutBuilder(builder: (context, constraints) {
      final height = constraints.maxHeight;
      return Container(
        padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: SizedBox(
          height: height,
          child: !isDesktop
              ? Stack(
                  children: [
                    // This is the trigger for the modal bottom sheet
                    InkWell(
                      onTap: () {
                        _showStatusSelectionSheet(
                          context,
                          ref,
                          orderStatusDisplayItems,
                          textStyle,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: context.containerLighterColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              orderStatusDisplayItems
                                  .firstWhere(
                                    (item) =>
                                        item.value ==
                                        ref
                                            .watch(orderViewModelProvider)
                                            .value
                                            ?.filterStatus,
                                    orElse: () => orderStatusDisplayItems.first,
                                  )
                                  .display,
                              style: textStyle,
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: context.componentNameTextColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (ref.watch(orderViewModelProvider).isLoading)
                      Positioned.fill(
                        child: Container(
                          color: context.containerColor.withOpacity(0.8),
                        ),
                      ),
                  ],
                )
              : Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: context.containerDarkerColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Wrap(
                            direction: Axis.horizontal,
                            spacing: 0, // hoặc 8.w nếu bạn muốn khoảng cách
                            children: [
                              ...orderStatusDisplayItems.map(
                                (status) {
                                  return _buildStatusItem(
                                    context,
                                    ref,
                                    status.display,
                                    isSelected: ref
                                            .watch(orderViewModelProvider)
                                            .value
                                            ?.filterStatus ==
                                        status.value,
                                    textStyle: textStyle,
                                    onTap: () {
                                      ref
                                          .read(orderViewModelProvider.notifier)
                                          .setFilterStatus(status.value);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (ref.watch(orderViewModelProvider).isLoading)
                      Positioned.fill(
                        child: Container(
                          color: context.containerColor.withOpacity(0.8),
                        ),
                      ),
                  ],
                ),
        ),
      );
    });
  }

  void _showStatusSelectionSheet(
    BuildContext context,
    WidgetRef ref,
    List<DisplayItem> items,
    TextStyle? textStyle,
  ) {
    final selectedValue = ref.read(orderViewModelProvider).value?.filterStatus;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.containerLighterColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  "Chọn trạng thái",
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.componentNameTextColor,
                    fontSize: 20.sp,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (ctx, index) {
                    final item = items[index];
                    final isSelected = item.value == selectedValue;
                    Color? statusColor;
                    switch (item.value) {
                      case 0:
                        statusColor = AppColors.cempedak100;
                        break;
                      case 1:
                        statusColor = AppColors.blueberry100;
                        break;
                      case 2:
                        statusColor = AppColors.teal100;
                        break;
                      case 3:
                        statusColor = AppColors.greenMint100;
                        break;
                      case 4:
                        statusColor = AppColors.rambutan100;
                        break;
                      default:
                        statusColor = context.componentNameTextColor;
                        break;
                    }
                    return ListTile(
                      leading: Container(
                        width: 10.w,
                        height: 10.h,
                        margin: EdgeInsets.only(left: 20.w, right: 20.w),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ),
                      title: Text(
                        item.display,
                        style: textStyle?.copyWith(
                          color: isSelected
                              ? AppColors.rambutan100
                              : context.componentNameTextColor,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check,
                              color: AppColors.rambutan100,
                            )
                          : null,
                      onTap: () {
                        ref
                            .read(orderViewModelProvider.notifier)
                            .setFilterStatus(item.value);
                        Navigator.pop(modalContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildStatusItem(
  BuildContext context,
  WidgetRef ref,
  String status, {
  bool isSelected = false,
  TextStyle? textStyle,
  required Function() onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      constraints: BoxConstraints(minWidth: 162.w),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            isSelected ? AppColors.rambutan100 : context.containerDarkerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: textStyle?.copyWith(
              color: isSelected
                  ? AppColors.neutral0
                  : context.componentNameTextLightColor,
            ) ??
            TextStyle(
              color: isSelected
                  ? AppColors.neutral0
                  : context.componentNameTextLightColor,
            ),
      ),
    ),
  );
}
