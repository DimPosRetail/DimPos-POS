import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/extensions/string_extension.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';

class CustomSearchFilterButtonBar extends StatefulWidget {
  final String? hintSearch;
  final Function(String searchValue) onSearch;
  final String Function(String)? validate;
  // final void Function() onApply;

  const CustomSearchFilterButtonBar({
    super.key,
    required this.onSearch,
    this.hintSearch,
    this.validate,
    // required this.onApply,
  });

  @override
  State<CustomSearchFilterButtonBar> createState() =>
      _CustomSearchFilterButtonBarState();
}

class _CustomSearchFilterButtonBarState
    extends State<CustomSearchFilterButtonBar> {
  late final TextEditingController _searchController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // if (widget.searchValue.isNotNullOrEmpty) {
    //   _searchController.text = widget.searchValue;
    // }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // @override
  // void didUpdateWidget(covariant CustomSearchFilterButtonBar oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.searchValue != widget.searchValue) {
  //     _searchController.text = widget.searchValue;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
    bool isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;

    double fontSize = isMobile ? 14.sp : 16.sp;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10.w,
          children: [
            Expanded(
              child: SearchBar(
                controller: _searchController,
                constraints: BoxConstraints(maxHeight: 40.h, minHeight: 40.h),
                backgroundColor: WidgetStateProperty.all(
                  context.containerDarkColor.withOpacity(0),
                ),
                elevation: WidgetStateProperty.all(2),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.w),
                    side: BorderSide(
                        color: context.componentNameTextLighterColor
                            .withOpacity(0.5)),
                  ),
                ),
                hintText: widget.hintSearch ?? 'Tìm kiếm',
                hintStyle: WidgetStateProperty.all(
                  context.bodySmall.copyWith(
                    color: context.componentNameTextLighterColor,
                    fontSize: fontSize,
                  ),
                ),
                textStyle: WidgetStateProperty.all(
                  context.bodySmall.copyWith(
                    color: context.componentNameTextDarkColor,
                    fontSize: fontSize,
                  ),
                ),
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                ),
                onChanged: (value) {},
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                shadowColor: WidgetStateProperty.all(
                    Color.fromRGBO(186, 186, 186, 0.15)),
              ),
            ),
            InkWell(
              onTap: () {
                final errorMessage =
                    widget.validate?.call(_searchController.text);
                if (errorMessage.isNotNullOrEmpty) {
                  setState(() {
                    _errorText = errorMessage;
                  });
                  return;
                }
                setState(() {
                  _errorText = null;
                });
                widget.onSearch(_searchController.text);
                // widget.onApply();
              },
              child: Container(
                // width: 40.w,
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile
                        ? 10.w
                        : isTablet
                            ? 30.w
                            : 40.w),
                alignment: Alignment.center,
                height: 40.h,
                decoration: BoxDecoration(
                    color: AppColors.rambutan100,
                    borderRadius: BorderRadius.circular(8.w)),
                child: Text(
                  "Áp dụng",
                  style: context.bodySmall.copyWith(
                    color: AppColors.neutral0,
                    fontWeight: FontWeight.w500,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_errorText.isNotNullOrEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 8.w),
            child: Text(
              _errorText!,
              style: context.titleMedium.copyWith(
                fontSize: fontSize,
                color: AppColors.rambutan100,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
