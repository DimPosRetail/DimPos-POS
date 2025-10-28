import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingNavigationBar extends StatefulWidget {
  final int currentIndex;
  const SettingNavigationBar({
    super.key,
    this.currentIndex = 0,
  });

  @override
  State<SettingNavigationBar> createState() => _SettingNavigationBarState();
}

class _SettingNavigationBarState extends State<SettingNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(
        icon: Assets.filledSetting,
        label: 'Cài đặt chung',
        route: Routes.setting,
      ),
      // _NavItem(
      //   icon: Assets.filledAccount,
      //   label: 'Tài khoản & Bảo mật',
      //   route: Routes.account,
      // ),
      // _NavItem(
      //   icon: Assets.filledData,
      //   label: 'Dữ liệu',
      //   route: Routes.data,
      // ),
      _NavItem(
        icon: Assets.filledPrinter,
        label: 'Máy in',
        route: Routes.printer,
      ),
    ];
    return SizedBox(
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // itemCount: 4,
        itemCount: 2,
        separatorBuilder: (ctx, index) => SizedBox(width: 12.w),
        itemBuilder: (ctx, index) => _buildNavItem(
          context,
          navItems[index],
          isSelected: widget.currentIndex == index,
          onTap: () => context.go(navItems[index].route),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    _NavItem item, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 200.w,
        padding: EdgeInsets.symmetric(
          vertical: 15.h,
          horizontal: 16.w,
        ),
        decoration: BoxDecoration(
          color: isSelected ? context.blurPrimaryColor : context.surfaceColor,
          borderRadius: BorderRadius.circular(20.w),
          border: isSelected
              ? Border.all(color: context.primaryColor, width: 1)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4.h,
          children: [
            Image.asset(
              item.icon,
              width: 28.sp,
              height: 28.sp,
              color: isSelected ? context.primaryColor : context.onSurfaceColor,
            ),
            Text(
              item.label,
              style: context.bodyMedium.copyWith(
                color:
                    isSelected ? context.primaryColor : context.onSurfaceColor,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String icon;
  final String label;
  final String route;

  _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
