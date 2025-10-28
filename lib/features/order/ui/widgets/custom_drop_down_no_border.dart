import 'package:dimpos_store/enums/order_status.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/common/models/display_item.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomDropdownNoBorderMenu extends StatefulWidget {
  final List<DisplayItem> lists;
  final DisplayItem? initialDisplayItem;
  final Function(int) onSelectedValueChange;
  final double? maxWidth;
  const CustomDropdownNoBorderMenu({
    super.key,
    required this.lists,
    this.initialDisplayItem,
    required this.onSelectedValueChange,
    this.maxWidth,
  });

  @override
  State<CustomDropdownNoBorderMenu> createState() =>
      _CustomDropdownNoBorderMenuState();
}

class _CustomDropdownNoBorderMenuState
    extends State<CustomDropdownNoBorderMenu> {
  late DisplayItem? _selected;
  @override
  void initState() {
    super.initState();
    if (widget.lists.isNotEmpty) {
      _selected = widget.initialDisplayItem;
    }
  }

  @override
  void didUpdateWidget(covariant CustomDropdownNoBorderMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDisplayItem != widget.initialDisplayItem) {
      _selected = widget.initialDisplayItem;
    }
  }

  void _onChangeSelectedValue(int? newValue) {
    // if (mounted) {
    //   setState(() {
    //     _selected = widget.lists.firstWhere(
    //       (item) => item.value == newValue,
    //     );
    //   });
    //   widget.onSelectedValueChange(widget.lists
    //       .firstWhere(
    //         (item) => item.value == newValue,
    //       )
    //       .value);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        height: 50.h,
        decoration: BoxDecoration(
          color: context.containerColor,
          borderRadius: BorderRadius.circular(20.w),
          // border: Border.all(color: context.containerDarkColor),
          boxShadow: [
            BoxShadow(
              color: context.containerDarkColor,
              blurRadius: 2.w,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: PopupMenuButton<int?>(
          offset: Offset(0.w, 55.h),
          constraints: BoxConstraints(
            minWidth: widget.maxWidth ?? 0.w,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.w),
          ),
          color: context.surfaceColor,
          initialValue:
              (widget.lists.contains(_selected)) ? (_selected?.value) : null,
          itemBuilder: (BuildContext ctx) {
            final RenderBox button = ctx.findRenderObject() as RenderBox;
            final buttonWidth = button.size.width;
            return widget.lists.map((DisplayItem table) {
              if (table.value == null) {
                return PopupMenuItem<int?>(
                  value: null,
                  child: SizedBox(
                    width: buttonWidth,
                    child: Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.h,
                          margin: EdgeInsets.only(left: 20.w, right: 20.w),
                          decoration: BoxDecoration(
                            color: context.containerDarkColor,
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                        ),
                        Text(
                          table.display,
                          style: context.bodySmall.copyWith(
                            color: context.onSurfaceColor,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              var orderStatus = OrderStatus.values.firstWhere(
                (e) => e.index == table.value,
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

              return PopupMenuItem<int?>(
                value: table.value,
                child: SizedBox(
                  width: buttonWidth,
                  child: Row(
                    children: [
                      Container(
                        width: 10.w,
                        height: 10.h,
                        margin: EdgeInsets.only(left: 20.w, right: 20.w),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ),
                      Text(
                        table.display,
                        style: context.bodySmall.copyWith(
                          color: context.onSurfaceColor,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList();
          },
          onSelected: (int? newValue) {
            _onChangeSelectedValue(newValue);
          },
          onCanceled: () {
            if (mounted) {
              setState(() {
                _selected = widget.lists.isNotEmpty ? widget.lists.first : null;
              });
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                // _selected,
                _selected?.display ?? '',
                style: context.bodySmall.copyWith(
                  color: context.onSurfaceColor,
                  fontSize: 16.sp,
                ),
              ),
              Container(
                width: 16.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: context.containerColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.keyboard_arrow_down_outlined,
                    size: 24.w,
                    color: context.componentNameTextDarkColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
