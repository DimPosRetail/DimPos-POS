// import 'dart:io';

import 'dart:io';

import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/features/authentication/repositories/authenticate_repository.dart';
import 'package:dimpos_store/features/common/ui/providers/app_theme_mode_provider.dart';
import 'package:dimpos_store/features/common/ui/providers/init_app.dart';
import 'package:dimpos_store/features/notification/ui/view_models/notification_hub_view_model.dart';
import 'package:dimpos_store/routing/router.dart';
import 'package:dimpos_store/utils/provider_observer.dart';
import 'package:dimpos_store/utils/request.dart';
import 'package:dimpos_store/utils/share_pref.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  HttpOverrides.global = MyHttpOverrides();
  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Configure web URL strategy
  // setUrlStrategy(PathUrlStrategy());

  runApp(
    ProviderScope(
      observers: [AppObserver()],
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('vi')],
        path: Assets.translation,
        fallbackLocale: const Locale('vi'),
        startLocale: const Locale('vi'),
        useOnlyLangCode: true,
        child: MainApp(),
      ),
    ),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  Future<void> initialization() async {
    final isLoggedIn = await ref.read(authenticateRepositoryProvider).isLogin();
    if (!context.mounted) return;
    if (isLoggedIn) {
      final accessToken = await getAccessToken();
      await ref
          .read(notificationHubViewModelProvider.notifier)
          .createHubConnection(accessToken!);
      await ref.read(initAppProvider.notifier).init();
      if (!context.mounted) return;
    }

    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(appThemeModeProvider);

    return _EagerInitialization(
      child: MaterialApp.router(
        title: 'DimPos Store',
        theme: context.lightTheme,
        darkTheme: context.darkTheme,
        themeMode: themeMode.value,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        builder: (context, child) => Scaffold(
          resizeToAvoidBottomInset: false,
          body: child,
        ),
      ),
    );
  }
}

class _EagerInitialization extends ConsumerWidget {
  final Widget child;

  const _EagerInitialization({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ToastificationWrapper(
      child: child,
    );
  }
}
