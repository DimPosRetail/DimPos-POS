import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/common/ui/widgets/header.dart';
import 'package:dimpos_store/features/setting/ui/widgets/setting_navigation_bar.dart';
import 'package:dimpos_store/routing/routes.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingScreen extends StatefulWidget {
  final Widget child;
  const SettingScreen({
    super.key,
    required this.child,
  });

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  // Update the selected index based on current route
  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(Routes.setting)) {
      _currentIndex = 0;
    }
    // else if (location == Routes.account) {
    //   _currentIndex = 1;
    // } else if (location == Routes.data) {
    //   _currentIndex = 2;
    // }
    else if (location == Routes.printer) {
      _currentIndex = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            Header(isMobile: isMobile),
            SizedBox(height: 20.h),
            SettingNavigationBar(
              currentIndex: _currentIndex,
            ),
            SizedBox(height: 20.h),
            widget.child,
          ],
        ),
      ),
    );
  }
}
