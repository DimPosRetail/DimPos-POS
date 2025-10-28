import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/extensions/string_extension.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:flutter/material.dart';

class OrderBadge extends StatelessWidget {
  final String title;
  final String? icon;
  final Function()? onTap;
  final bool isHavingChoosenValue;
  final bool isDisabled;
  final bool isWarning;
  const OrderBadge({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.isHavingChoosenValue = false,
    this.isDisabled = false,
    this.isWarning = false,
  });
  @override
  Widget build(BuildContext context) {
    return (icon.isNotNullOrEmpty)
        ? Stack(
            children: [
              InkWell(
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.containerColor,
                    border: Border.all(
                      color: isWarning
                          ? AppColors.cempedak100
                          : isHavingChoosenValue
                              ? AppColors.rambutan100
                              : isDisabled
                                  ? context.componentNameTextLightColor
                                      .withOpacity(0.3)
                                  : context.componentNameTextLightColor,
                    ),
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            icon!,
                            width: 20.w,
                            height: 20.h,
                            color: isWarning
                                ? AppColors.cempedak100
                                : isHavingChoosenValue
                                    ? AppColors.rambutan100
                                    : isDisabled
                                        ? context.onSurfaceColor
                                            .withOpacity(0.3)
                                        : context.onSurfaceColor,
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Text(
                            title,
                            style: context.bodySmall.copyWith(
                              color: isWarning
                                  ? AppColors.cempedak100
                                  : isHavingChoosenValue
                                      ? AppColors.rambutan100
                                      : isDisabled
                                          ? context.onSurfaceColor
                                              .withOpacity(0.3)
                                          : context.onSurfaceColor,
                              fontSize: 16.sp,
                              fontWeight: isHavingChoosenValue
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                      isWarning
                          ? Icon(
                              Icons.info_rounded,
                              size: 20,
                              fill: 0,
                              color: isHavingChoosenValue
                                  ? AppColors.cempedak100
                                  : isDisabled
                                      ? context.onSurfaceColor.withOpacity(0.3)
                                      : context.onSurfaceColor,
                            )
                          : Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              fill: 0,
                              color: isHavingChoosenValue
                                  ? AppColors.rambutan100
                                  : isDisabled
                                      ? context.onSurfaceColor.withOpacity(0.3)
                                      : context.onSurfaceColor,
                            ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: context.containerColor,
                border: Border.all(
                  color: isWarning
                      ? AppColors.cempedak100
                      : isHavingChoosenValue
                          ? AppColors.rambutan100
                          : isDisabled
                              ? context.componentNameTextLightColor
                                  .withOpacity(0.3)
                              : context.componentNameTextLightColor,
                ),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: context.bodySmall.copyWith(
                      color: isWarning
                          ? AppColors.cempedak100
                          : isHavingChoosenValue
                              ? AppColors.rambutan100
                              : isDisabled
                                  ? context.onSurfaceColor.withOpacity(0.3)
                                  : context.onSurfaceColor,
                      fontSize: 16.sp,
                      fontWeight: isHavingChoosenValue
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  isWarning
                      ? Icon(
                          Icons.info_rounded,
                          size: 20,
                          fill: 0,
                          color: AppColors.cempedak100,
                        )
                      : Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          fill: 0,
                          color: isHavingChoosenValue
                              ? AppColors.rambutan100
                              : isDisabled
                                  ? context.onSurfaceColor.withOpacity(0.3)
                                  : context.onSurfaceColor,
                        ),
                ],
              ),
            ),
          );
  }
}
