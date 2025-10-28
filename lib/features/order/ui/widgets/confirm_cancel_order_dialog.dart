import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';

class ConfirmCancelOrderDialog extends StatefulWidget {
  final String orderId;
  const ConfirmCancelOrderDialog({
    super.key,
    required this.orderId,
  });

  @override
  State<ConfirmCancelOrderDialog> createState() =>
      _ConfirmCancelOrderDialogState();
}

class _ConfirmCancelOrderDialogState extends State<ConfirmCancelOrderDialog> {
  final TextEditingController _reasonController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedReason;
  bool _isOtherReason = false;
  final List<String> _cancelReasons = [
    'Khách hàng yêu cầu hủy',
    'Sản phẩm hết hàng',
    'Thông tin đơn hàng không chính xác',
    'Vấn đề về thanh toán',
    'Khác...',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;

    return Dialog(
      backgroundColor: context.surfaceColor,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24.w : 100.w,
        vertical: isMobile ? 24.h : 80.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.w),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 400.w,
          maxHeight:
              isMobile ? 350.h : 450.h, // Tăng chiều cao để có chỗ cho dropdown
        ),
        padding: EdgeInsets.all(isMobile ? 20.w : 24.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hủy đơn hàng',
                style: context.labelMedium.copyWith(
                  fontSize: isMobile ? 18.sp : 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 16.h : 20.h),
              Text(
                'Mã đơn hàng: ${widget.orderId.split('-').last}',
                style: context.labelMedium.copyWith(
                  fontSize: isMobile ? 14.sp : 16.sp,
                  color: context.componentNameTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 16.h : 20.h),
              Text(
                'Lý do hủy đơn hàng',
                style: context.labelMedium.copyWith(
                  fontSize: isMobile ? 14.sp : 16.sp,
                  fontWeight: FontWeight.w400,
                  color: context.componentNameTextColor,
                ),
              ),
              SizedBox(height: 8.h),

              // Hiển thị Dropdown hoặc TextFormField tùy theo trạng thái
              if (!_isOtherReason) ...[
                // Dropdown để chọn lý do
                DropdownButtonFormField<String>(
                  value: _selectedReason,
                  decoration: InputDecoration(
                    hintText: 'Chọn lý do hủy đơn hàng',
                    hintStyle: context.labelMedium.copyWith(
                      color: context.componentNameTextColor,
                      fontSize: isMobile ? 14.sp : 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide:
                          BorderSide(color: context.componentNameTextColor),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                  items: _cancelReasons.map((String reason) {
                    return DropdownMenuItem<String>(
                      value: reason,
                      child: Text(
                        reason,
                        style: context.labelMedium.copyWith(
                          fontSize: isMobile ? 14.sp : 16.sp,
                          color: context.componentNameTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      if (value == 'Khác...') {
                        _isOtherReason = true;
                        _selectedReason = null;
                        _reasonController.clear();
                      } else {
                        _selectedReason = value;
                        _reasonController.text = value ?? '';
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn lý do hủy đơn hàng';
                    }
                    return null;
                  },
                ),
              ] else ...[
                // TextFormField để nhập lý do tùy chỉnh
                TextFormField(
                  controller: _reasonController,
                  style: context.bodyMedium.copyWith(
                    color: context.onSurfaceColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Nhập lý do hủy đơn hàng...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: isMobile ? 14.sp : 16.sp,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập lý do hủy đơn hàng';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8.h),
                // Nút quay lại dropdown
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isOtherReason = false;
                        _reasonController.clear();
                        _selectedReason = null;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Quay lại danh sách',
                          style: context.labelMedium.copyWith(
                            fontSize: isMobile ? 12.sp : 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: isMobile ? 20.h : 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      child: Text(
                        'Hủy',
                        style: context.labelMedium.copyWith(
                          fontSize: isMobile ? 14.sp : 16.sp,
                          color: context.componentNameTextLighterColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final String reason = _reasonController.text.trim();
                          Navigator.of(context).pop(reason);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rambutan100,
                        foregroundColor: context.surfaceColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                      ),
                      child: Text(
                        'Xác nhận',
                        style: context.labelMedium.copyWith(
                          fontSize: isMobile ? 14.sp : 16.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.neutral0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
