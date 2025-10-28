import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/setting/ui/widgets/setting_section.dart';
import 'package:flutter/material.dart';

class DataScreen extends StatelessWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sectionDataAsyncItems = [
      SectionItem(
        title: 'Cập nhập dữ liệu',
        subtitle: 'Cập nhập lần cuối lúc 14:09 - 19/05/2025',
        isDataAsyncMode: true,
      ),
      SectionItem(
        title: 'Tự động đồng bộ',
      ),
    ];

    final sectionDataManagementItems = [
      SectionItem(
        title: 'Xuất dữ liệu',
      ),
      SectionItem(
        title: 'Nhập dữ liệu',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20.h,
      children: [
        SettingSection(
          title: 'Cập nhập dữ liệu',
          items: sectionDataAsyncItems,
        ),
        SettingSection(
          title: 'Quản lý dữ liệu',
          items: sectionDataManagementItems,
        ),
      ],
    );
  }
}
