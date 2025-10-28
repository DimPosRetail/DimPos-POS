import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:flutter/material.dart';

class DateTimeBadge extends StatelessWidget {
  final String dateTime;
  final String icon;
  const DateTimeBadge({
    super.key,
    required this.dateTime,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [context.boxShadow],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 6.w,
        children: [
          Image.asset(
            icon,
            width: 20.w,
            height: 20.h,
            color: context.primaryColor,
          ),
          Text(
            dateTime,
            style: context.bodySmall.copyWith(
              color: context.onSurfaceColor,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}
