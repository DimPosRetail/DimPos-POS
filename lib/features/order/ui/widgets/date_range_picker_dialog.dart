import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePickerDialog extends StatefulWidget {
  final DateTime? initialFromDate;
  final DateTime? initialToDate;
  final Function(DateTime? fromDate, DateTime? toDate) onDateRangeSelected;

  const DateRangePickerDialog({
    super.key,
    this.initialFromDate,
    this.initialToDate,
    required this.onDateRangeSelected,
  });

  @override
  State<DateRangePickerDialog> createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<DateRangePickerDialog> {
  DateTime? _fromDate;
  DateTime? _toDate;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Set default values with same logic as repository
    _fromDate = widget.initialFromDate ??
        DateTime(now.year, now.month, now.day, 0, 0, 0);
    _toDate = widget.initialToDate ??
        DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  Future<void> _selectFromDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _toDate != null
          ? DateTime(_toDate!.year, _toDate!.month, _toDate!.day)
          : DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.rambutan100,
                  onPrimary: Colors.white,
                ),
            dialogBackgroundColor: context.onSurfaceColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Set time to 00:00:00 for fromDate
        _fromDate = DateTime(picked.year, picked.month, picked.day, 0, 0, 0);

        // If toDate is now before fromDate, adjust toDate
        if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
          _toDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        }
      });
    }
  }

  Future<void> _selectToDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: _fromDate != null
          ? DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day)
          : DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.rambutan100,
                  onPrimary: Colors.white,
                ),
            dialogBackgroundColor: context.onSurfaceColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Set time to 23:59:59 for toDate
        _toDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);

        // If fromDate is now after toDate, adjust fromDate
        if (_fromDate != null && _fromDate!.isAfter(_toDate!)) {
          _fromDate = DateTime(picked.year, picked.month, picked.day, 0, 0, 0);
        }
      });
    }
  }

  void _resetToToday() {
    final now = DateTime.now();
    setState(() {
      _fromDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
      _toDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    });
  }

  bool _isValidDateRange() {
    if (_fromDate == null || _toDate == null) return false;
    return !_fromDate!.isAfter(_toDate!);
  }

  String? _getValidationMessage() {
    if (_fromDate == null) return 'Vui lòng chọn ngày bắt đầu';
    if (_toDate == null) return 'Vui lòng chọn ngày kết thúc';
    if (_fromDate!.isAfter(_toDate!)) {
      return 'Ngày bắt đầu không thể lớn hơn ngày kết thúc';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24.w : 300.w,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.w),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: context.containerColor,
          borderRadius: BorderRadius.circular(16.w),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Chọn khoảng thời gian',
              style: context.titleLarge.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: context.componentNameTextColor,
              ),
            ),
            SizedBox(height: 24.h),

            // From Date
            _buildDateSelector(
              label: 'Từ ngày',
              date: _fromDate,
              onTap: _selectFromDate,
            ),
            SizedBox(height: 16.h),

            // To Date
            _buildDateSelector(
              label: 'Đến ngày',
              date: _toDate,
              onTap: _selectToDate,
            ),
            SizedBox(height: 24.h),

            // Reset button
            Center(
              child: TextButton.icon(
                onPressed: _resetToToday,
                icon: Icon(
                  Icons.today,
                  size: 18.sp,
                  color: AppColors.rambutan100,
                ),
                label: Text(
                  'Hôm nay',
                  style: context.titleMedium.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.rambutan100,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Validation message
            if (_getValidationMessage() != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.w),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 16.sp,
                      color: Colors.red,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _getValidationMessage()!,
                        style: context.titleMedium.copyWith(
                          fontSize: 12.sp,
                          color: Colors.red,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Hủy',
                    style: context.titleMedium.copyWith(
                      fontSize: 14.sp,
                      color: context.componentNameTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                ElevatedButton(
                  onPressed: _isValidDateRange()
                      ? () {
                          widget.onDateRangeSelected(_fromDate, _toDate);
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isValidDateRange()
                        ? AppColors.rambutan100
                        : context.componentNameTextLighterColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    elevation: _isValidDateRange() ? 2 : 0,
                  ),
                  child: Text(
                    'Áp dụng',
                    style: context.titleMedium.copyWith(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.titleMedium.copyWith(
            fontSize: 14.sp,
            color: context.componentNameTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: context.componentNameTextLighterColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? _dateFormat.format(date) : 'Chọn ngày',
                  style: context.titleMedium.copyWith(
                    fontSize: 14.sp,
                    color: date != null
                        ? context.componentNameTextColor
                        : context.componentNameTextLighterColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18.sp,
                  color: context.componentNameTextLighterColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
