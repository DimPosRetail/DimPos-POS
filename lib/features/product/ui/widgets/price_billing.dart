import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/currency_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:flutter/material.dart';

class PriceBilling extends StatelessWidget {
  final String title;
  final double price;
  final bool isTotal;
  final double? paddingWidth;

  const PriceBilling(
      {super.key,
      required this.title,
      required this.price,
      this.isTotal = false,
      this.paddingWidth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: (paddingWidth == null) ? 3.h : (paddingWidth! + 3.h),
          vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: isTotal
                ? context.titleMedium.copyWith(
                    color: context.onSurfaceColor,
                    fontSize: 18.sp,
                  )
                : context.bodySmall.copyWith(
                    color: context.componentNameTextDarkColor,
                    fontSize: 14.sp,
                  ),
          ),
          Text(
            price.currency,
            style: isTotal
                ? context.titleMedium.copyWith(
                    color: context.onSurfaceColor,
                    fontSize: 18.sp,
                  )
                : context.bodySmall.copyWith(
                    color: context.componentNameTextDarkColor,
                    fontSize: 14.sp,
                  ),
          ),
        ],
      ),
    );
  }
}
