import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/constants/language.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/authentication/ui/view_models/authentication_view_model.dart';
import 'package:dimpos_store/features/common/ui/providers/init_app.dart';
import 'package:dimpos_store/features/home/states/sidebar_state.dart';
import 'package:dimpos_store/features/notification/ui/view_models/notification_hub_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/financial_shift_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/menu_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/store_view_model.dart';
import 'package:dimpos_store/routing/routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends ConsumerWidget {
  final int currentIndex;

  const AppSidebar({
    super.key,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pictureUrl =
        ref.watch(storeViewModelProvider).value?.storeInfo?.pictureUrl;
    final isExpanded = ref.watch(sidebarStateProvider);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isExpanded ? 180.w : 70.w,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [context.boxShadow],
      ),
      child: Column(
        children: [
          _buildLogoSection(pictureUrl, isExpanded, context, ref),
          Flexible(
            child: _buildNavigationItems(isExpanded, context),
          ),
          _buildAccountOptions(
            context,
            isExpanded: isExpanded,
            onLogout: () {
              ref.read(authenticationViewModelProvider.notifier).logout();
              ref
                  .read(notificationHubViewModelProvider.notifier)
                  .stopHubConnection();
            },
            ref: ref,
          ),
        ],
      ),
    );
    // Container(
    //   width: 180.w,
    //   decoration: BoxDecoration(
    //     color: context.surfaceColor,
    //     boxShadow: [context.boxShadow],
    //   ),
    //   child: Column(
    //     children: [
    //       _buildLogoSection(pictureUrl),
    //       Flexible(
    //         child: _buildNavigationItems(),
    //       ),
    //       _buildAccountOptions(
    //         context,
    //         onLogout: () {
    //           ref.read(authenticationViewModelProvider.notifier).logout();
    //           ref
    //               .read(notificationHubViewModelProvider.notifier)
    //               .stopHubConnection();
    //         },
    //         ref: ref,
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget _buildLogoSection(
    String? pictureUrl,
    bool isExpanded,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Column(
      children: [
        if (pictureUrl != null && pictureUrl.isNotEmpty)
          Container(
            alignment: Alignment.center,
            child: Image.network(
              pictureUrl,
              height: isExpanded ? 120.h : 60.h,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            padding: EdgeInsets.only(
              top: 20.h,
              bottom: 10.h,
              left: isExpanded ? 20.w : 0,
            ),
            alignment: isExpanded ? Alignment.centerLeft : Alignment.center,
            child: Image.asset(
              Assets.logo,
              height: isExpanded ? 60.h : 40.h,
            ),
          ),
        // Toggle button
        InkWell(
          onTap: () => ref.read(sidebarStateProvider.notifier).toggle(),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Icon(
              isExpanded ? Icons.chevron_left : Icons.chevron_right,
              color: context.onSurfaceColor,
              size: 24.sp,
            ),
          ),
        ),
        Divider(height: 1, color: context.onSurfaceColor.withOpacity(0.1)),
      ],
    );
    // if (pictureUrl != null && pictureUrl.isNotEmpty) {
    //   return Container(
    //     // padding: EdgeInsets.only(top: 20.h),
    //     alignment: Alignment.centerLeft,
    //     child: Image.network(
    //       pictureUrl,
    //       height: isExpanded ? 120.h : 60.h,
    //       fit: BoxFit.cover,
    //     ),
    //   );
    // } else {
    //   return Container(
    //     padding: EdgeInsets.only(
    //       top: 20.h,
    //       bottom: 10.h,
    //       left: isExpanded ? 20.w : 0,
    //     ),
    //     alignment: isExpanded ? Alignment.centerLeft : Alignment.center,
    //     child: Image.asset(
    //       Assets.logo,
    //       height: isExpanded ? 60.h : 40.h,
    //     ),

    //   );
    // }
  }

  Widget _buildNavigationItems(bool isExpanded, BuildContext context) {
    final navItems = [
      _NavItem(
        icon: Assets.menu,
        label: Language.menu.tr(),
        route: Routes.product,
      ),
      _NavItem(
        icon: Assets.order,
        label: Language.order.tr(),
        route: Routes.order,
      ),
      _NavItem(
        icon: Assets.setting,
        label: Language.settings.tr(),
        route: Routes.setting,
      ),
    ];

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      itemCount: navItems.length,
      itemBuilder: (context, index) {
        final item = navItems[index];
        final isSelected = index == currentIndex;

        return _buildNavItem(
          context,
          icon: item.icon,
          label: item.label,
          route: item.route,
          isExpanded: isExpanded,
          isSelected: isSelected,
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String icon,
    required String label,
    required String route,
    required bool isExpanded,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 15.h,
          horizontal: isExpanded ? 16.w : 8.w,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment:
              isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 22.sp,
              color: isSelected ? context.primaryColor : context.onSurfaceColor,
            ),
            if (isExpanded) ...[
              SizedBox(width: 12.w),
              Text(
                label,
                style: context.bodyMedium.copyWith(
                  color: isSelected
                      ? context.primaryColor
                      : context.onSurfaceColor,
                  fontSize: 16.sp,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Build account options at the bottom
  Widget _buildAccountOptions(
    BuildContext context, {
    required VoidCallback onLogout,
    required bool isExpanded,
    required WidgetRef ref,
  }) {
    return Container(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        children: [
          _buildAccountOption(
            context,
            icon: Assets.update,
            label: "Cập nhập",
            isExpanded: isExpanded,
            onTap: () {
              ref.read(menuViewModelProvider.notifier).getMenu();
              ref.read(cartViewModelProvider.notifier).getCarts(0);
              ref
                  .read(financialShiftViewModelProvider.notifier)
                  .checkFinancialShiftOpen();
            },
          ),
          _buildAccountOption(
            context,
            icon: Assets.logout,
            label: Language.logout.tr(),
            isExpanded: isExpanded,
            onTap: () {
              // Implement logout logic
              onLogout();
              ref.read(initAppProvider.notifier).dispose();
              context.go(Routes.splash);
            },
          ),
        ],
      ),
    );
  }

  // Build individual account option
  Widget _buildAccountOption(
    BuildContext context, {
    required String icon,
    required String label,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 15.h,
          horizontal: 16.w,
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: 22.sp,
              color: context.onSurfaceColor,
            ),
            if (isExpanded) ...[
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: context.bodyMedium.copyWith(
                    color: context.onSurfaceColor,
                    fontSize: 16.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// Helper class to define navigation items
class _NavItem {
  final String icon;
  final String label;
  final String route;

  _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
