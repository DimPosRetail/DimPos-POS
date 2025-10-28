import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/features/authentication/repositories/authenticate_repository.dart';
import 'package:dimpos_store/features/common/ui/providers/init_app.dart';
import 'package:dimpos_store/features/notification/ui/view_models/notification_hub_view_model.dart';
import 'package:dimpos_store/routing/routes.dart';
import 'package:dimpos_store/utils/share_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _checkLoginStatus(ref, context);
    return Scaffold(
      body: Center(
        child: Image.asset(
          Assets.logo,
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}

Future<void> _checkLoginStatus(WidgetRef ref, BuildContext context) async {
  final isLoggedIn = await ref.read(authenticateRepositoryProvider).isLogin();
  // await Future.delayed(const Duration(seconds: 1));
  if (!context.mounted) return;
  if (isLoggedIn) {
    final accessToken = await getAccessToken();
    await ref
        .read(notificationHubViewModelProvider.notifier)
        .createHubConnection(accessToken!);
    await ref.read(initAppProvider.notifier).init();
    if (!context.mounted) return;
    context.pushReplacement(Routes.product);
  } else {
    context.pushReplacement(Routes.login);
  }
}
