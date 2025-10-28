import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:flutter/material.dart';

Widget customButtonStack(
  BuildContext context,
  String functionName, {
  double? buttonHeight,
  double? buttonWidth,
  Color buttonColor = AppColors.rambutan100,
  Color? borderColor,
  double borderWidth = 0.0,
  double fontSize = 16.0,
  required Function()? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: buttonHeight ?? 50.h,
      width: buttonWidth ?? double.infinity,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(100.w),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: borderWidth,
        ),
      ),
      child: Center(
        child: Text(
          functionName,
          style: context.titleMedium.copyWith(
            color: (buttonColor == AppColors.rambutan100)
                ? AppColors.neutral0
                : context.componentNameTextDarkColor,
            fontSize: fontSize,
          ),
        ),
      ),
    ),
  );
}
