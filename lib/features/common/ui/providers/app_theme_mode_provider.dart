import 'package:dimpos_store/utils/share_pref.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_theme_mode_provider.g.dart';

@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  Future<ThemeMode> build() async {
    final currentMode = await getThemeMode();
    return ThemeMode.values.firstWhere(
      (value) => currentMode == value.name,
      orElse: () => ThemeMode.light,
    );
  }

  Future<void> updateMode(ThemeMode mode) async {
    state = AsyncData(mode);
    await setThemeMode(mode.name);
  }
}
