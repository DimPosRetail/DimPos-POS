import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowErrorDialog extends ConsumerWidget {
  final String errorMessage;
  const ShowErrorDialog({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;

    TextStyle textStyle = context.titleMedium.copyWith(
      color: context.componentNameTextColor,
      fontWeight: isMobile ? FontWeight.w500 : FontWeight.w400,
      fontSize: 18.sp,
    );

    final iconSize = 24.w;

    final imageSizeWidth = isMobile ? 200.w : 200.w;
    // final imageSizeHeight = 60.h;
    final image = Image.asset(
      Assets.loadingError,
      width: imageSizeWidth,
      fit: BoxFit.cover,
    );

    double dialogSize = MediaQuery.of(context).size.height * 0.5;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24.w : 100.w,
        vertical: isMobile ? 24.h : 80.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.w),
      ),
      child: Container(
        width: dialogSize,
        height: dialogSize * 2 / 3,
        decoration: BoxDecoration(
          color: context.containerColor,
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: context.containerDarkColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8.w),
                margin: EdgeInsets.fromLTRB(0, 8.w, 8.w, 0),
                child: Icon(Icons.close, size: iconSize, color: Colors.black),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: image,
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.containerColor,
                  borderRadius: BorderRadius.circular(15.w),
                ),
                child: Text(
                  errorMessage,
                  style: textStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
