import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/common/models/display_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomDropdownMenu extends ConsumerStatefulWidget {
  final List<DisplayItem> lists;
  final DisplayItem? initialDisplayItem;
  final Function(String) onSelectedValueChange;
  const CustomDropdownMenu(
      {super.key,
      required this.lists,
      this.initialDisplayItem,
      required this.onSelectedValueChange});
  @override
  ConsumerState<CustomDropdownMenu> createState() => CustomDropdownMenuState();
}

class CustomDropdownMenuState extends ConsumerState<CustomDropdownMenu> {
  late DisplayItem? _selected;
  @override
  void initState() {
    super.initState();
    if (widget.lists.isNotEmpty) {
      _selected = widget.initialDisplayItem;
    }
  }

  @override
  void didUpdateWidget(covariant CustomDropdownMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDisplayItem != widget.initialDisplayItem) {
      _selected = widget.initialDisplayItem;
    }
  }

  void _onChangeSelectedValue(String newValue) {
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
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        height: 50.h,
        decoration: BoxDecoration(
            color: context.containerColor,
            borderRadius: BorderRadius.circular(20.w),
            border: Border.all(color: context.containerDarkColor)),
        child: PopupMenuButton<String>(
          offset: Offset(16.w, 30.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.w),
          ),
          color: context.surfaceColor,
          initialValue: (widget.lists.contains(_selected))
              ? _selected?.value.toString()
              : null,
          itemBuilder: (BuildContext ctx) {
            final RenderBox button = ctx.findRenderObject() as RenderBox;
            final buttonWidth = button.size.width;
            return widget.lists.map((DisplayItem table) {
              return PopupMenuItem<String>(
                value: table.value.toString(),
                child: SizedBox(
                  width: buttonWidth,
                  child: Text(
                    table.display,
                    style: context.bodySmall.copyWith(
                      color: context.onSurfaceColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              );
            }).toList();
          },
          onSelected: (String newValue) {
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
                    Icons.edit,
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
