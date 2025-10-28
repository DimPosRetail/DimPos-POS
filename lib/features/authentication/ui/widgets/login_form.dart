import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/authentication/ui/view_models/authentication_view_model.dart';
import 'package:dimpos_store/features/common/ui/providers/init_app.dart';
import 'package:dimpos_store/features/notification/ui/view_models/notification_hub_view_model.dart';
import 'package:dimpos_store/routing/routes.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/exception.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  // bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
    final isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
    // final isDesktop = SizeConfig.getDeviceType() == DeviceType.desktop;

    final isLoading = ref.watch(authenticationViewModelProvider).isLoading ||
        ref.watch(initAppProvider).isLoading;
    // print('Loading state: $isLoading');
    final componentNameFontSize = 18.sp;
    final componentNameFontWeight = FontWeight.w600;
    final hintTextFontSize = 18.sp;
    final hintTextFontWeight = FontWeight.w400;
    final hintPadding = 20.w;
    final buttonTextFontSize = 20.sp;
    final buttonTextFontWeight = FontWeight.w500;
    final componentSpacingHeight = isMobile
        ? 20.h
        : isTablet
            ? 20.h
            : 25.h;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tên đăng nhập',
            style: context.labelSmall.copyWith(
                color: context.componentNameTextDarkColor,
                fontSize: componentNameFontSize,
                fontWeight: componentNameFontWeight),
          ),
          SizedBox(height: 10.h),
          TextFormField(
            controller: _usernameController,
            style: context.bodyMedium.copyWith(
              color: context.onSurfaceColor,
              fontSize: hintTextFontSize,
              fontWeight: hintTextFontWeight,
            ),
            decoration: InputDecoration(
              filled: true,
              hintText: 'Tên đăng nhập',
              contentPadding: EdgeInsets.only(left: hintPadding),
              hintStyle: context.labelSmall.copyWith(
                color: context.hintTextColor,
                fontSize: hintTextFontSize,
                fontWeight: hintTextFontWeight,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.neutral20,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: context.primaryColor,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: context.primaryColor,
                ),
              ),
              fillColor: context.containerColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập tên đăng nhập';
              }
              return null;
            },
          ),
          SizedBox(height: componentSpacingHeight),
          Text(
            'Mật khẩu',
            style: context.labelSmall.copyWith(
              color: context.componentNameTextDarkColor,
              fontSize: componentNameFontSize,
              fontWeight: componentNameFontWeight,
            ),
          ),
          SizedBox(height: 10.h),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: context.bodyMedium.copyWith(
              color: context.onSurfaceColor,
              fontSize: hintTextFontSize,
              fontWeight: hintTextFontWeight,
            ),
            decoration: InputDecoration(
              suffixIcon: InkWell(
                onTap: _togglePasswordVisibility,
                child: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: context.componentNameTextDarkColor,
                  fill: 0.1,
                ),
              ),
              filled: true,
              hintText: 'Mật khẩu',
              contentPadding: EdgeInsets.only(left: hintPadding),
              hintStyle: context.labelSmall.copyWith(
                color: context.hintTextColor,
                fontSize: hintTextFontSize,
                fontWeight: hintTextFontWeight,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.w),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.w),
                borderSide: const BorderSide(
                  color: AppColors.neutral20,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.w),
                borderSide: BorderSide(
                  color: context.primaryColor,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.w),
                borderSide: BorderSide(
                  color: context.primaryColor,
                ),
              ),
              fillColor: context.containerColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              return null;
            },
          ),
          SizedBox(height: componentSpacingHeight + 15.h),
          SizedBox(
            width: double.infinity,
            height: 60.h,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final user = await ref
                              .read(authenticationViewModelProvider.notifier)
                              .login(
                                username: _usernameController.text,
                                password: _passwordController.text,
                              );
                          if (user?.accessToken != null) {
                            await ref
                                .read(notificationHubViewModelProvider.notifier)
                                .createHubConnection(user!.accessToken);
                          }
                          await ref.read(initAppProvider.notifier).init();
                          if (!context.mounted) return;
                          context.go(Routes.product);
                        } catch (e) {
                          if (!context.mounted) return;
                          handleApiError(error: e as DioException);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                padding: EdgeInsets.symmetric(
                  vertical: 16.h,
                  horizontal: 32.w,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? CircularProgressIndicator(
                      color: AppColors.rambutan90,
                    )
                  : Text(
                      'Đăng nhập',
                      style: context.titleMedium.copyWith(
                        color: AppColors.neutral0,
                        fontSize: buttonTextFontSize,
                        fontWeight: buttonTextFontWeight,
                        height: 1.2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
