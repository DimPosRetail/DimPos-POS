import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/financial_shift_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/menu_view_model.dart';
import 'package:dimpos_store/features/setting/ui/widgets/setting_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeneralSettingScreen extends ConsumerWidget {
  const GeneralSettingScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionThemeItems = [
      SectionItem(
        title: 'Chế độ tối',
        icon: Icons.dark_mode,
        isThemeMode: true,
      ),
      // SectionItem(
      //   title: 'Toàn màn hình',
      //   icon: Icons.fullscreen,
      //   isFullScreen: true,
      // ),
    ];
    // final storeOperationSetingItems = [
    //   SectionItem(
    //     title: 'Số lượng bàn',
    //     icon: Icons.table_bar_rounded,
    //     isTableAmountMode: true,
    //   ),
    // ];
    final sectionGeneralSettingsItems = [
      SectionItem(
        title: 'Tất cả thông báo',
        icon: Icons.notifications_active_rounded,
        isNotificationMode: true,
      ),
      SectionItem(
        title: 'Số lượng bàn',
        icon: Icons.table_bar_rounded,
        isTableAmountMode: true,
      ),
      SectionItem(
        title: 'Cập nhật',
        icon: Icons.update_rounded,
        // isCurrencyMode: true,
        onTap: () {
          ref.read(menuViewModelProvider.notifier).getMenu();
          ref.read(cartViewModelProvider.notifier).getCarts(0);
          ref
              .read(financialShiftViewModelProvider.notifier)
              .checkFinancialShiftOpen();
        },
      ),
      // SectionItem(
      //   title: 'Trợ năng',
      //   icon: Icons.extension_rounded,
      // ),
      // SectionItem(
      //   title: 'Trợ giúp',
      //   icon: Icons.help_rounded,
      // ),
      // SectionItem(
      //   title: 'Pháp lý & Chính sách',
      //   icon: Icons.policy_rounded,
      // ),
    ];
    final sectionLanguageItems = [
      SectionItem(
        title: 'Ngôn ngữ',
        icon: Icons.language_rounded,
        isLanguageMode: true,
      ),
    ];

    final sectionLogoutItems = [
      SectionItem(
        title: 'Đăng xuất',
        icon: Icons.logout_rounded,
        isLogout: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20.h,
        children: [
          SettingSection(
            title: 'Giao diện',
            items: sectionThemeItems,
          ),
          // SettingSection(
          //   title: 'Vận hành cửa hàng',
          //   items: storeOperationSetingItems,
          // ),
          SettingSection(
            title: 'Cài đặt chung',
            items: sectionGeneralSettingsItems,
          ),
          SettingSection(
            title: 'Ngôn ngữ',
            items: sectionLanguageItems,
          ),
          SettingSection(
            title: 'Điều hướng',
            items: sectionLogoutItems,
          ),
        ],
      ),
    );
  }
}
