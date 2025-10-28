import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/setting/ui/widgets/setting_section_item.dart';
import 'package:flutter/material.dart';

class SettingSection extends StatelessWidget {
  final String title;
  final List<SectionItem> items;
  final Widget? button;

  const SettingSection({
    super.key,
    required this.title,
    required this.items,
    this.button,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12.w, bottom: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: context.titleMedium.copyWith(
                  fontSize: 18.sp,
                  color: context.onSurfaceColor,
                ),
              ),
              if (button != null)
                Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: button!,
                ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: Column(
            children: [
              for (var item in items)
                Column(
                  children: [
                    SettingSectionItem(
                      title: item.title,
                      icon: item.icon,
                      subtitle: item.subtitle,
                      isThemeMode: item.isThemeMode,
                      isNotificationMode: item.isNotificationMode,
                      isDataAsyncMode: item.isDataAsyncMode,
                      isLanguageMode: item.isLanguageMode,
                      isFaceIdMode: item.isFaceIdMode,
                      isTableAmountMode: item.isTableAmountMode,
                      isLogout: item.isLogout,
                      onTap: item.onTap, // Add this line
                    ),
                    if (items.last != item)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey[200],
                        ),
                      )
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class SectionItem {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool isThemeMode;
  final bool isNotificationMode;
  final bool isDataAsyncMode;
  final bool isLanguageMode;
  final bool isFaceIdMode;
  final bool isTableAmountMode;
  final bool isLogout;
  final VoidCallback? onTap; // Add this line

  const SectionItem({
    required this.title,
    this.icon,
    this.subtitle,
    this.isThemeMode = false,
    this.isNotificationMode = false,
    this.isDataAsyncMode = false,
    this.isLanguageMode = false,
    this.isFaceIdMode = false,
    this.isTableAmountMode = false,
    this.isLogout = false,
    this.onTap, // Add this line
  });
}
