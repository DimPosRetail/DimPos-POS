import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/features/authentication/ui/login_screen.dart';
import 'package:dimpos_store/features/home/ui/home_screen.dart';
import 'package:dimpos_store/features/management/ui/management_screen.dart';
import 'package:dimpos_store/features/membership/ui/membership_screen.dart';
import 'package:dimpos_store/features/onboarding/ui/splash_screen.dart';
import 'package:dimpos_store/features/order/ui/order_screen.dart';
import 'package:dimpos_store/features/product/ui/cart_screen.dart';
import 'package:dimpos_store/features/product/ui/product_screen.dart';
import 'package:dimpos_store/features/setting/ui/general_setting_screen.dart';
import 'package:dimpos_store/features/setting/ui/printer_screen.dart';
import 'package:dimpos_store/features/setting/ui/setting_screen.dart';
import 'package:dimpos_store/routing/routes.dart';
import 'package:dimpos_store/utils/share_pref.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: Routes.splash,
  debugLogDiagnostics: true,
  redirect: (BuildContext context, GoRouterState state) async {
    if (context.mounted) {
      SizeConfig.init(context);
    }
    if (state.matchedLocation == Routes.cart &&
        SizeConfig.getDeviceType() == DeviceType.desktop) {
      return Routes.product;
    }
    if (await getAccessToken() == null || await getRefreshToken() == null) {
      return Routes.login;
    }

    if (state.matchedLocation == Routes.login) {
      return Routes.product;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: Routes.splash,
      pageBuilder: (context, state) => NoTransitionPage(
        child: SplashScreen(),
      ),
    ),
    ShellRoute(
      pageBuilder: (BuildContext context, GoRouterState state, Widget child) {
        return NoTransitionPage(
          child: HomeScreen(
            child: child,
          ),
        );
      },
      routes: [
        GoRoute(
          path: Routes.product,
          pageBuilder: (context, state) => NoTransitionPage(
            child: ProductScreen(),
          ),
        ),
        GoRoute(
          path: Routes.cart,
          pageBuilder: (context, state) => NoTransitionPage(
            child: CartScreen(),
          ),
        ),
        GoRoute(
          path: Routes.order,
          pageBuilder: (context, state) => NoTransitionPage(
            child: OrderScreen(),
          ),
        ),
        ShellRoute(
          pageBuilder:
              (BuildContext context, GoRouterState state, Widget child) {
            return NoTransitionPage(
              child: SettingScreen(
                child: child,
              ),
            );
          },
          routes: [
            GoRoute(
              path: Routes.setting,
              pageBuilder: (context, state) => NoTransitionPage(
                child: GeneralSettingScreen(),
              ),
            ),
            // GoRoute(
            //   path: Routes.account,
            //   pageBuilder: (context, state) => NoTransitionPage(
            //     child: AccountScreen(),
            //   ),
            // ),
            // GoRoute(
            //   path: Routes.data,
            //   pageBuilder: (context, state) => NoTransitionPage(
            //     child: DataScreen(),
            //   ),
            // ),
            GoRoute(
              path: Routes.printer,
              pageBuilder: (context, state) => NoTransitionPage(
                child: PrinterScreen(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: Routes.membership,
          pageBuilder: (context, state) => NoTransitionPage(
            child: MembershipScreen(),
          ),
        ),
        GoRoute(
          path: Routes.management,
          pageBuilder: (context, state) => NoTransitionPage(
            child: ManagementScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: Routes.login,
      pageBuilder: (context, state) => NoTransitionPage(
        child: const LoginScreen(),
      ),
    ),
  ],
);
