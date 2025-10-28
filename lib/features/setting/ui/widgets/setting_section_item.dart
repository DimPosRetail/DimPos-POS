import 'package:dimpos_store/enums/language.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/authentication/ui/view_models/authentication_view_model.dart';
import 'package:dimpos_store/features/common/states/table_amount_setting.dart';
import 'package:dimpos_store/features/common/ui/providers/app_theme_mode_provider.dart';
import 'package:dimpos_store/features/common/ui/providers/init_app.dart';
import 'package:dimpos_store/features/notification/ui/view_models/notification_hub_view_model.dart';
import 'package:dimpos_store/routing/routes.dart';
import 'package:dimpos_store/utils/logger_config.dart';
import 'package:dimpos_store/utils/share_pref.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _LanguageOption {
  final String id;
  final String name;
  final Language code;
  final String flag;

  const _LanguageOption({
    required this.id,
    required this.name,
    required this.code,
    required this.flag,
  });
}

final _languages = [
  const _LanguageOption(
      id: '0', name: 'Tiếng Việt', code: Language.vi, flag: ''),
  const _LanguageOption(id: '1', name: 'English', code: Language.en, flag: ''),
];

class SettingSectionItem extends ConsumerStatefulWidget {
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
  final VoidCallback? onTap; // Add this parameter

  const SettingSectionItem({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.isThemeMode = false,
    this.isNotificationMode = false,
    this.isDataAsyncMode = false,
    this.isLanguageMode = false,
    this.isFaceIdMode = false,
    this.isTableAmountMode = false,
    this.isLogout = false,
    this.onTap, // Add this parameter
  });

  @override
  ConsumerState<SettingSectionItem> createState() => _SettingSectionItemState();
}

class _SettingSectionItemState extends ConsumerState<SettingSectionItem> {
  _LanguageOption selectedLanguage = _languages.first;

  @override
  Widget build(BuildContext context) {
    bool value = false;
    var tableAmount;
    if (widget.isThemeMode) {
      value = ref.watch(appThemeModeProvider).value == ThemeMode.dark;
    }

    if (widget.isLanguageMode) {
      selectedLanguage = _languages.firstWhere(
        (e) => e.code.name == context.locale.languageCode,
      );
    }

    if (widget.isTableAmountMode) {
      tableAmount = ref.watch(tableAmountSettingProvider);
    }

    if (widget.isNotificationMode) {
      value = ref.watch(notificationHubViewModelProvider).value?.isConnected ??
          false;
    }

    if (widget.isThemeMode ||
        widget.isNotificationMode ||
        widget.isDataAsyncMode ||
        widget.isFaceIdMode) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Row(
          children: [
            if (widget.icon != null)
              Icon(
                widget.icon,
                size: 22.w,
                color: Colors.grey[700],
              ),
            if (widget.icon != null) SizedBox(width: 16.w),
            Expanded(
              child: Text(
                widget.title,
                style: context.bodyMedium.copyWith(
                  fontSize: 16.sp,
                  color: context.onSurfaceColor,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: (value) async {
                if (widget.isThemeMode) {
                  ref.read(appThemeModeProvider.notifier).updateMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                } else if (widget.isNotificationMode) {
                  if (value) {
                    final accessToken = await getAccessToken();
                    if (accessToken == null) return;
                    ref
                        .read(notificationHubViewModelProvider.notifier)
                        .createHubConnection(accessToken);
                  } else {
                    ref
                        .read(notificationHubViewModelProvider.notifier)
                        .stopHubConnection();
                  }
                } else if (widget.isDataAsyncMode) {
                  // Handle data async mode change
                } else if (widget.isFaceIdMode) {
                  // Handle face ID mode change
                }
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      );
    }

    if (widget.isLogout) {
      return InkWell(
        onTap: () {
          providerLogger.d('Logout action triggered');
          ref.read(authenticationViewModelProvider.notifier).logout();
          ref.read(initAppProvider.notifier).dispose();
          context.go(Routes.splash);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(
                widget.icon ?? Icons.logout_rounded,
                size: 22.w,
                color: context.primaryColor,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  widget.title,
                  style: context.bodyMedium.copyWith(
                    fontSize: 16.sp,
                    color: context.primaryColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20.w,
                color: context.primaryColor,
              ),
            ],
          ),
        ),
      );
    }

    if (widget.isTableAmountMode) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 22.w,
              color: Colors.grey[700],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                widget.title,
                style: context.bodyMedium.copyWith(
                  fontSize: 16.sp,
                  color: context.onSurfaceColor,
                ),
              ),
            ),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    if (mounted)
                      ref.read(tableAmountSettingProvider.notifier).decrement();
                  },
                  child: Icon(
                    Icons.remove,
                    size: 26.w,
                    fill: 1,
                    color: context.componentNameTextDarkColor,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.h),
                  width: 50.w,
                  child: Text(
                    '$tableAmount',
                    textAlign: TextAlign.center,
                    style: context.bodyMedium.copyWith(
                      fontSize: 16.sp,
                      color: context.onSurfaceColor,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (mounted)
                      ref.read(tableAmountSettingProvider.notifier).increment();
                  },
                  child: Icon(
                    Icons.add,
                    size: 26.w,
                    color: context.componentNameTextDarkColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (widget.isLanguageMode) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 22.w,
              color: Colors.grey[700],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                widget.title,
                style: context.bodyMedium.copyWith(
                  fontSize: 16.sp,
                  color: context.onSurfaceColor,
                ),
              ),
            ),
            PopupMenuButton<_LanguageOption>(
              tooltip: "Chọn ngôn ngữ",
              position: PopupMenuPosition.under,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.w),
              ),
              color: context.surfaceColor,
              initialValue: selectedLanguage,
              itemBuilder: (ctx) => _languages.map((e) {
                return PopupMenuItem<_LanguageOption>(
                  value: e,
                  child: Text(
                    e.name,
                    style: context.bodyMedium.copyWith(
                      fontSize: 16.sp,
                      color: context.onSurfaceColor,
                    ),
                  ),
                );
              }).toList(),
              onSelected: (value) {
                context.setLocale(
                  Locale(value.code.name),
                );
              },
              child: Row(
                children: [
                  Text(
                    selectedLanguage.name,
                    style: context.bodyMedium.copyWith(
                      fontSize: 16.sp,
                      color: context.onSurfaceColor,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.chevron_right,
                    size: 20.w,
                    color: context.onSurfaceColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Default case - this is where we use the custom onTap or default behavior
    return InkWell(
      onTap: widget.onTap ??
          () {}, // Use custom onTap if provided, otherwise empty function
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            if (widget.icon != null)
              Icon(
                widget.icon,
                size: 22.w,
                color: Colors.grey[700],
              ),
            if (widget.icon != null) SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.h,
                children: [
                  Text(
                    widget.title,
                    style: context.bodyMedium.copyWith(
                      fontSize: 16.sp,
                      color: context.onSurfaceColor,
                    ),
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: context.bodySmall.copyWith(
                        fontSize: 12.sp,
                        color: context.subColor,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20.w,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
