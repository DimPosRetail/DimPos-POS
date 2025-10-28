import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/iterable_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/common/ui/widgets/show_error_dialog.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/promotion_view_model.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/exception.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PromotionDialog extends ConsumerWidget {
  const PromotionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    final bool isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
    final bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;

    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double popupWidthPercentTage = isMobile
        ? 1
        : isTablet
            ? 0.6
            : 0.5;
    double popupHeightPercentTage = isMobile
        ? 0.5
        : isTablet
            ? 0.6
            : 0.85;
    double popupMaxHeight = screenHeight * popupHeightPercentTage;
    double popupMaxWidth = screenWidth * popupWidthPercentTage;
    double popupPaddingHorizon =
        isMobile ? 10.w : 20.w; // Fixed height for each item
    double popupPaddingVertical =
        isMobile ? 8.w : 16.w; // Fixed height for each item

    // Calculate desired item dimensions based on device type
    double desiredHeight;
    int crossAxisCount;

    switch (SizeConfig.getDeviceType()) {
      case DeviceType.mobile:
        crossAxisCount = 1;
        desiredHeight = 80.h; // Your original height
        break;
      case DeviceType.tablet:
        crossAxisCount = 1;
        desiredHeight = 100.h;
        break;
      default:
        crossAxisCount = 1; // More items per row on desktop
        desiredHeight = 150.h;
        break;
    }
    final horizontalSpacing =
        5.w * (crossAxisCount - 1); // Total spacing between items
    final availableWidth = SizeConfig.screenWidth -
        horizontalSpacing -
        (16.w); // Subtracting padding
    final itemWidth = availableWidth / crossAxisCount;

    final childAspectRatio = (itemWidth / desiredHeight);

    final promotionRuleViewModel = ref.watch(promotionViewModelProvider);
    final cartState = ref.watch(cartViewModelProvider).value;
    final currentCart = cartState?.carts?[cartState.selectedCartIndex];

    if (promotionRuleViewModel.isLoading) {
      return Center(
        child: SizedBox(
          width: 40.w,
          height: 40.h,
          child: CircularProgressIndicator(
            color: AppColors.rambutan100,
          ),
        ),
      );
    }

    if (promotionRuleViewModel.value?.promotionRules.isNullOrEmpty == true) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24.w : 100.w,
          vertical: isMobile ? 24.h : 80.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.w),
        ),
        child: Container(
          width: popupMaxWidth,
          height: popupMaxHeight,
          decoration: BoxDecoration(
            color: context.containerDarkerColor,
            boxShadow: [context.boxShadow],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              "Không có mã giảm giá nào",
              style: context.bodyMedium.copyWith(
                color: context.componentNameTextDarkColor,
                fontSize: 20.sp,
              ),
            ),
          ),
        ),
      );
    }

    if (promotionRuleViewModel.hasError) {
      return ShowErrorDialog(
        errorMessage: "Đã có lỗi xảy ra khi tải khuyến mãi",
      );
    }

    final allPromotions = promotionRuleViewModel.value?.promotionRules;
    final promotionValidityMap = allPromotions == null
        ? <String, bool>{}
        : {for (var promo in allPromotions) promo.id: promo.isValid};

    final hasInvalidAppliedPromotions = currentCart?.promotionsApplied?.any(
            (appliedPromo) =>
                promotionValidityMap[appliedPromo.promotionRuleId] == false) ??
        false;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24.w : 100.w,
        vertical: isMobile ? 24.h : 80.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.w),
      ),
      child: Container(
        width: popupMaxWidth,
        height: popupMaxHeight,
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [context.boxShadow],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Container(
              width: popupMaxWidth,
              padding: EdgeInsets.all(popupPaddingVertical),
              decoration: BoxDecoration(
                color: context.containerDarkerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10.h : 20.w,
                            horizontal: popupPaddingHorizon),
                        child: Text(
                          'Mã giảm giá',
                          textAlign: TextAlign.left,
                          style: context.titleMedium.copyWith(
                            fontSize: 24,
                            color: context.componentNameTextDarkColor,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          context.pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: popupPaddingHorizon),
                          child: const Icon(Icons.close,
                              size: 24, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  // Container(
                  //   padding: EdgeInsets.fromLTRB(popupPaddingHorizon, 0.w,
                  //       popupPaddingHorizon, popupPaddingVertical),
                  //   child: CustomSearchFilterButtonBar(
                  //     hintSearch: "Nhập mã giảm giá",
                  //     onSearch: (String searchValue) {},
                  //   ),
                  // ),

                  // --- WIDGET MỚI: Nút "Bỏ chọn các voucher không hợp lệ" ---
                  if (hasInvalidAppliedPromotions)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          popupPaddingHorizon, 0, popupPaddingHorizon, 8.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              if (currentCart == null ||
                                  currentCart.promotionsApplied.isNullOrEmpty) {
                                return;
                              }

                              final idsToRemove = currentCart.promotionsApplied!
                                  .where((appliedPromo) =>
                                      promotionValidityMap[
                                          appliedPromo.promotionRuleId] ==
                                      false)
                                  .map((appliedPromo) => appliedPromo.id)
                                  .toList();

                              if (idsToRemove.isNotEmpty) {
                                try {
                                  await ref
                                      .read(cartViewModelProvider.notifier)
                                      .removePromotionFromCart(
                                        cartId: currentCart.id,
                                        promotionIds: idsToRemove,
                                      );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  handleApiError(
                                    error: e as DioException,
                                  );
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Bỏ chọn các voucher không hợp lệ",
                              style: context.bodyMedium.copyWith(
                                color: AppColors.rambutan100,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.rambutan100,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    // padding: const EdgeInsets.all(8.0),
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.all(0.w),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: isMobile ? 10.w : 15.w,
                              childAspectRatio: childAspectRatio,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final promotionRule = promotionRuleViewModel
                                    .value!.promotionRules![index];
                                return _buildPromotionRuleOption(
                                  context,
                                  itemWidth,
                                  name: promotionRule.name,
                                  shortDescription:
                                      promotionRule.shortDescription ?? "N/A",
                                  edgeInsets: EdgeInsets.fromLTRB(
                                      popupPaddingHorizon,
                                      0.w,
                                      popupPaddingHorizon,
                                      0.w),
                                  isSelected: currentCart?.promotionsApplied
                                          ?.any((rule) =>
                                              rule.promotionRuleId ==
                                              promotionRule.id) ??
                                      false,
                                  isValid: promotionRule.isValid,
                                  onTap: promotionRule.isValid
                                      ? () async {
                                          if (currentCart?.promotionsApplied
                                                  ?.any((rule) =>
                                                      rule.promotionRuleId ==
                                                      promotionRule.id) ??
                                              false) {
                                            try {
                                              final promotionId =
                                                  currentCart?.promotionsApplied
                                                      ?.firstWhere(
                                                        (rule) =>
                                                            rule.promotionRuleId ==
                                                            promotionRule.id,
                                                      )
                                                      .id;
                                              if (promotionId != null) {
                                                await ref
                                                    .read(
                                                  cartViewModelProvider
                                                      .notifier,
                                                )
                                                    .removePromotionFromCart(
                                                  cartId: currentCart?.id ?? "",
                                                  promotionIds: [promotionId],
                                                );
                                              }
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              handleApiError(
                                                error: e as DioException,
                                              );
                                            }
                                          } else {
                                            try {
                                              await ref
                                                  .read(
                                                    cartViewModelProvider
                                                        .notifier,
                                                  )
                                                  .applyPromotionToCart(
                                                    cartId:
                                                        currentCart?.id ?? "",
                                                    promotionRule:
                                                        promotionRule.copyWith(
                                                      isSelected: true,
                                                    ),
                                                  );
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              handleApiError(
                                                error: e as DioException,
                                              );
                                            }
                                          }
                                        }
                                      : null,
                                );
                              },
                              childCount: promotionRuleViewModel
                                  .value!.promotionRules!.length,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if ((cartState?.isUpdatingCart ?? true) ||
                (promotionRuleViewModel.value?.isLoading ?? false))
              Positioned.fill(
                child: Container(
                  color: context.containerColor.withOpacity(0.8),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _buildPromotionRuleOption(
  BuildContext context,
  double itemWidth, {
  required String name,
  required String shortDescription,
  EdgeInsets? edgeInsets,
  required bool isSelected,
  required bool isValid,
  required Function()? onTap,
}) {
  final bool isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
  final bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;

  final double promotionNameSize = isMobile
      ? 14.sp
      : isTablet
          ? 16.sp
          : 18.sp;

  return Container(
    margin: edgeInsets ?? EdgeInsets.all(8.w),
    decoration: BoxDecoration(
      color: isValid
          ? context.containerDarkColor.withOpacity(0.5)
          : context.containerDarkColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10.w),
    ),
    child: InkWell(
      onTap: isValid ? onTap : null,
      borderRadius: BorderRadius.circular(10.w),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isSelected,
                onChanged: isValid ? (_) => onTap?.call() : null,
                activeColor: isValid
                    ? AppColors.rambutan100
                    : context.componentNameTextLighterColor,
              ),
            ),

            SizedBox(width: isMobile ? 8.w : 12.w),

            // Content
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Promotion name on the left
                  Flexible(
                    flex: 2,
                    child: Text(
                      name,
                      style: context.titleSmall.copyWith(
                        color: isValid
                            ? context.componentNameTextDarkColor
                            : context.componentNameTextLighterColor,
                        fontSize: promotionNameSize,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(width: isMobile ? 8.w : 16.w),

                  // Short description on the right
                  Flexible(
                    flex: 3,
                    child: Text(
                      shortDescription,
                      style: context.titleSmall.copyWith(
                        color: isValid
                            ? context.componentNameTextColor
                            : context.componentNameTextLighterColor,
                        fontSize: promotionNameSize,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
// Widget _buildPromotionRuleOption(
//   BuildContext context,
//   double itemWidth, {
//   required String name,
//   required String shortDescription,
//   EdgeInsets? edgeInsets,
//   required bool isSelected,
//   required bool isValid,
//   required Function()? onTap,
// }) {
//   final bool isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
//   final bool isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;

//   // Simplified font size calculation since RadioListTile handles much of the sizing
//   final double promotionNameSize = isMobile
//       ? 14.sp
//       : isTablet
//           ? 16.sp
//           : 18.sp;

//   return Container(
//     margin: edgeInsets ?? EdgeInsets.all(8.w),
//     decoration: BoxDecoration(
//       color: isValid
//           ? context.containerDarkColor.withOpacity(0.5)
//           : context.containerDarkColor.withOpacity(0.2),
//       borderRadius: BorderRadius.circular(10.w),
//     ),
//     child: CheckboxListTile(
//       value: isSelected,
//       onChanged: isValid ? (_) => onTap?.call() : null,
//       title: Align(
//         alignment: Alignment.centerLeft,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           spacing: isMobile ? 8.w : 16.w,
//           children: [
//             // Promotion name on the left
//             Flexible(
//               flex: 2,
//               child: Text(
//                 name,
//                 style: context.titleSmall.copyWith(
//                   color: isValid
//                       ? context.componentNameTextDarkColor
//                       : context.componentNameTextLighterColor,
//                   fontSize: promotionNameSize,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),

//             // Short description on the right
//             Flexible(
//               flex: 3,
//               child: Text(
//                 shortDescription,
//                 style: context.titleSmall.copyWith(
//                   color: isValid
//                       ? context.componentNameTextColor
//                       : context.componentNameTextLighterColor,
//                   fontSize: promotionNameSize,
//                   fontWeight: FontWeight.w400,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 textAlign: TextAlign.end,
//               ),
//             ),
//           ],
//         ),
//       ),
//       contentPadding: EdgeInsets.all(10.w),
//       dense: false,
//       activeColor: isValid
//           ? AppColors.rambutan100
//           : context.componentNameTextLighterColor,
//       controlAffinity: ListTileControlAffinity.leading,
//     ),
//   );
// }
