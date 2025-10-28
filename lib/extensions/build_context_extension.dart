import 'package:dimpos_store/constants/fonts.dart';
import 'package:dimpos_store/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

extension ThemeModeExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get onPrimaryColor => Theme.of(this).colorScheme.onPrimary;
  Color get onSurfaceColor => Theme.of(this).colorScheme.onSurface;
  Color get onBackgroundColor => Theme.of(this).colorScheme.onSurface;
  Color get onErrorColor => Theme.of(this).colorScheme.onError;
  Color get onSecondaryColor => Theme.of(this).colorScheme.onSecondary;
  Color get onTertiaryColor => Theme.of(this).colorScheme.onTertiary;
  Color get containerLightColor => isDarkMode
      ? Color.fromRGBO(7, 6, 2, 1)
      : Color.fromRGBO(248, 249, 253, 1);
  Color get containerLighterColor => isDarkMode
      ? Color.fromRGBO(7, 6, 2, 1)
      : Color.fromRGBO(254, 254, 254, 1);
  Color get containerColor => isDarkMode
      ? Color.fromRGBO(7, 6, 2, 1)
      : Color.fromRGBO(248, 249, 253, 1);
  Color get containerDarkerColor => isDarkMode
      ? Color.fromRGBO(34, 34, 33, 1)
      : Color.fromRGBO(244, 244, 250, 1);
  Color get containerDarkColor =>
      isDarkMode ? Color.fromRGBO(34, 34, 33, 1) : Color(0xFFD7DBEC);
  Color get disabledColor => isDarkMode
      ? Color.fromRGBO(129, 132, 92, 1)
      : Color.fromRGBO(126, 132, 163, 1);
  Color get disabledColorLighter => isDarkMode
      ? Color.fromRGBO(129, 132, 92, 0.5)
      : Color.fromRGBO(126, 132, 163, 0.5);
  Color get disabledColorDarker => isDarkMode
      ? Color.fromRGBO(129, 132, 92, 0.2)
      : Color.fromRGBO(126, 132, 163, 0.2);
  Color get subColor => isDarkMode
      ? Color.fromRGBO(129, 132, 92, 1)
      : Color.fromRGBO(126, 132, 163, 1);
  Color get hintTextColor => isDarkMode
      ? AppColors.neutral20.withOpacity(0.5)
      : AppColors.neutral50.withOpacity(0.5);
  Color get componentNameTextLightColor =>
      isDarkMode ? AppColors.neutral40 : AppColors.neutral60;
  Color get componentNameTextLighterColor =>
      isDarkMode ? AppColors.neutral50 : AppColors.neutral50;
  Color get componentNameTextColor =>
      isDarkMode ? AppColors.neutral10 : AppColors.neutral90;
  Color get componentNameTextDarkColor =>
      isDarkMode ? AppColors.neutral0 : AppColors.neutral100;
  Color get buttonTextColor =>
      isDarkMode ? AppColors.neutral100 : AppColors.neutral0;
  // Color get selectedComponentRambutan10 =>
  //     isDarkMode ? AppColors.rambutan100.withOpacity(0.1) : AppColors.rambutan10;

  Color get blurPrimaryColor => Color.fromRGBO(253, 231, 234, 1);
  Color get blurBorderColor =>
      isDarkMode ? AppColors.neutral0 : AppColors.neutral50.withOpacity(0.5);

  BoxShadow get boxShadow => BoxShadow(
        color: Color.fromRGBO(186, 186, 186, 0.15),
        offset: Offset(0, 6),
        blurRadius: 9,
        spreadRadius: -5,
      );
  BoxShadow get boxShadowDark => BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.15),
        offset: Offset(0, 6),
        blurRadius: 9,
        spreadRadius: -5,
      );
  BoxShadow get boxShadowLight => BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.05),
        offset: Offset(0, 6),
        blurRadius: 9,
        spreadRadius: -5,
      );

  // text theme
  TextStyle get displayLarge => Theme.of(this).textTheme.displayLarge!;
  TextStyle get displayMedium => Theme.of(this).textTheme.displayMedium!;
  TextStyle get displaySmall => Theme.of(this).textTheme.displaySmall!;
  TextStyle get headlineLarge => Theme.of(this).textTheme.headlineLarge!;
  TextStyle get headlineMedium => Theme.of(this).textTheme.headlineMedium!;
  TextStyle get headlineSmall => Theme.of(this).textTheme.headlineSmall!;
  TextStyle get titleLarge => Theme.of(this).textTheme.titleLarge!;
  TextStyle get titleMedium => Theme.of(this).textTheme.titleMedium!;
  TextStyle get titleSmall => Theme.of(this).textTheme.titleSmall!;
  TextStyle get bodyLarge => Theme.of(this).textTheme.bodyLarge!;
  TextStyle get bodyMedium => Theme.of(this).textTheme.bodyMedium!;
  TextStyle get bodySmall => Theme.of(this).textTheme.bodySmall!;
  TextStyle get labelLarge => Theme.of(this).textTheme.labelLarge!;
  TextStyle get labelMedium => Theme.of(this).textTheme.labelMedium!;
  TextStyle get labelSmall => Theme.of(this).textTheme.labelSmall!;

  ThemeData get lightTheme => ThemeData.light().copyWith(
        scaffoldBackgroundColor: AppColors.mono0,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.rambutan100,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.rambutan100,
          surface: AppColors.mono0,
          onSurface: AppColors.mono100,
        ),
        textTheme: Theme.of(this)
            .textTheme
            .apply(
              bodyColor: AppColors.mono100,
              fontFamily: AppFonts.inter,
            )
            .copyWith(
              displayLarge: AppTheme.headLineLarge32,
              displayMedium: AppTheme.titleExtraLarge24,
              displaySmall: AppTheme.titleLarge20,
              headlineLarge: AppTheme.titleLarge20,
              headlineMedium: AppTheme.titleMedium18,
              headlineSmall: AppTheme.titleSmall16,
              titleLarge: AppTheme.titleLarge20,
              titleMedium: AppTheme.titleMedium18,
              titleSmall: AppTheme.titleSmall16,
              bodyLarge: AppTheme.bodyHuge20,
              bodyMedium: AppTheme.bodyLarge16,
              bodySmall: AppTheme.bodyMedium14,
              labelLarge: AppTheme.bodyMedium14,
              labelMedium: AppTheme.bodySmall12,
              labelSmall: AppTheme.bodySmall12,
            ),
      );

  ThemeData get darkTheme => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.mono100,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.rambutan100,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.rambutan100,
          surface: AppColors.mono100,
          onSurface: AppColors.mono0,
        ),
        textTheme: Theme.of(this)
            .textTheme
            .apply(
              bodyColor: AppColors.mono20,
              fontFamily: AppFonts.inter,
            )
            .copyWith(
              displayLarge: AppTheme.headLineLarge32,
              displayMedium: AppTheme.titleExtraLarge24,
              displaySmall: AppTheme.titleLarge20,
              headlineLarge: AppTheme.titleLarge20,
              headlineMedium: AppTheme.titleMedium18,
              headlineSmall: AppTheme.titleSmall16,
              titleLarge: AppTheme.titleLarge20,
              titleMedium: AppTheme.titleMedium18,
              titleSmall: AppTheme.titleSmall16,
              bodyLarge: AppTheme.bodyHuge20,
              bodyMedium: AppTheme.bodyLarge16,
              bodySmall: AppTheme.bodyMedium14,
              labelLarge: AppTheme.bodyMedium14,
              labelMedium: AppTheme.bodySmall12,
              labelSmall: AppTheme.bodySmall12,
            ),
      );
}
