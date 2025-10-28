import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/home/ui/widgets/app_sidebar.dart';
import 'package:dimpos_store/routing/routes.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Widget child;

  const HomeScreen({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  // Update the selected index based on current route
  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(Routes.product)) {
      _currentIndex = 0;
    } else if (location == Routes.cart) {
      _currentIndex = 1;
    } else if (location == Routes.order) {
      _currentIndex = 2;
    } else if (location == Routes.setting ||
        location == Routes.account ||
        location == Routes.data ||
        location == Routes.printer) {
      _currentIndex = 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    SizeConfig.init(context);
    // final isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
    final isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
    final isDesktop = SizeConfig.getDeviceType() == DeviceType.desktop;
    final isLandscape = SizeConfig.isLandscape();


    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            if (isDesktop || (isTablet && isLandscape))
              AppSidebar(
                  currentIndex:
                      _currentIndex > 1 ? _currentIndex - 1 : _currentIndex),
            // Main content area
            Expanded(
              child: Container(
                color: context.containerColor,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (!(isDesktop || (isTablet && isLandscape))) ? _buildBottomNav() : null,
    );
  }

  // Optional bottom navigation for mobile
  Widget? _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        // Navigate based on index
        switch (index) {
          case 0:
            context.go(Routes.product);
            break;
          case 1:
            context.go(Routes.cart);
            break;
          case 2:
            context.go(Routes.order);
            break;
          case 3:
            context.go(Routes.setting);
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: context.surfaceColor,
      selectedItemColor: context.primaryColor,
      unselectedItemColor: context.onSurfaceColor,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset(
            Assets.menu,
            width: 30.sp,
            color: _currentIndex == 0
                ? context.primaryColor
                : context.onSurfaceColor,
          ),
          label: 'menu'.tr(),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.shopping_cart_outlined,
            size: 30.sp,
            color: _currentIndex == 1
                ? context.primaryColor
                : context.onSurfaceColor,
          ),
          label: 'Giỏ hàng',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            Assets.order,
            width: 30.sp,
            color: _currentIndex == 2
                ? context.primaryColor
                : context.onSurfaceColor,
          ),
          label: 'Đơn hàng',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            Assets.setting,
            width: 30.sp,
            color: _currentIndex == 3
                ? context.primaryColor
                : context.onSurfaceColor,
          ),
          label: 'settings'.tr(),
        ),
      ],
    );
  }
}
