import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/product/ui/view_models/financial_shift_view_model.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/exception.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class ConfirmFinancialShiftDialog extends ConsumerWidget {
  const ConfirmFinancialShiftDialog({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
    final isLoading = ref.watch(financialShiftViewModelProvider).isLoading;
    return Dialog(
      backgroundColor: context.surfaceColor,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24.w : 100.w,
        vertical: isMobile ? 24.h : 80.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.w),
      ),
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 400.w,
              maxHeight: isMobile ? 400.h : 400.h,
            ),
            padding: EdgeInsets.all(isMobile ? 20.w : 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Xác nhận đóng ca',
                  style: TextStyle(
                    fontSize: isMobile ? 18.sp : 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 16.h : 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.confirm,
                      fit: BoxFit.cover,
                      // width: isMobile ? 60.w : 80.w,
                      // height: isMobile ? 60.h : 80.h,
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 20.h : 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 10.w,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: EdgeInsets.symmetric(
                          vertical: 16.h,
                          horizontal: 20.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: isMobile ? 14.sp : 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await ref
                              .read(financialShiftViewModelProvider.notifier)
                              .closeShift();
                          toastification.show(
                            type: ToastificationType.success,
                            style: ToastificationStyle.fillColored,
                            title: Text("Đóng ca thành công"),
                            description:
                                Text("Ca tài chính đã được đóng thành công."),
                            autoCloseDuration: const Duration(seconds: 3),
                            alignment: Alignment.topRight,
                          );
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        } catch (e) {
                          handleApiError(error: e as DioException);
                        }
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
                        'Xác nhận',
                        style: TextStyle(
                          fontSize: isMobile ? 14.sp : 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: context.containerColor.withOpacity(0.8),
                child: Center(
                  child: CircularProgressIndicator(
                    color: context.primaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
