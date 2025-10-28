import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/setting/ui/widgets/setting_section.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sectionAccountManagementItems = [
      SectionItem(
        title: 'Thông tin cá nhân',
        icon: Icons.person_rounded,
      ),
      SectionItem(
        title: 'Thiết lập Mật khẩu',
        icon: Icons.lock_rounded,
      ),
      SectionItem(
        title: 'Xác thực bằng Khuôn mặt',
        icon: Icons.face_6,
        isFaceIdMode: true,
      ),
    ];

    final sectionLoginManagementItems = [
      SectionItem(
        title: 'Kiểm tra hoạt động Tài khoản',
        subtitle:
            'Kiểm tra những lần đăng nhập và thay đổi tài khoản trong 30 ngày gần nhất',
        icon: Icons.privacy_tip_rounded,
      ),
      SectionItem(
        title: 'Quản lý Thiết bị đăng nhập',
        subtitle: 'Quản lý các thiết bị đã đăng nhập vào tài khoản DimPos',
        icon: Icons.devices_other_rounded,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20.h,
      children: [
        SettingSection(
          title: 'Quản lý tài khoản',
          items: sectionAccountManagementItems,
        ),
        SettingSection(
          title: 'Quản lý đăng nhập',
          items: sectionLoginManagementItems,
        ),
      ],
    );
  }
}
