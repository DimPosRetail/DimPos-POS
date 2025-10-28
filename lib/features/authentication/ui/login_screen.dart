import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/authentication/ui/widgets/login_form.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
    final isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
    final isDesktop = SizeConfig.getDeviceType() == DeviceType.desktop;

    final largeTitleFontSize = isMobile
        ? 40.sp
        : isTablet
            ? 50.sp
            : 60.sp;
    final componentSpacingHeight = isMobile
        ? 20.h
        : isTablet
            ? 30.h
            : 40.h;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: !isMobile ? 30.w : 0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 20.h, bottom: 10.h),
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          Assets.logo,
                          height: 60.h,
                        ),
                      ),
                      SizedBox(height: componentSpacingHeight),
                      Text(
                        'Đăng nhập',
                        style: context.displayLarge.copyWith(
                          color: context.onSurfaceColor,
                          fontSize: largeTitleFontSize,
                        ),
                      ),
                      SizedBox(height: componentSpacingHeight),
                      const LoginForm(),
                    ],
                  ),
                ),
              ),
            ),
            if (isDesktop)
              Container(
                width: 700.w,
                height: double.infinity,
                margin: EdgeInsets.all(30.w),
                child: Center(
                  child: Image.asset(
                    Assets.welcome,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
