import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/currency_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/features/home/states/sidebar_state.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/menu_view_model.dart';
import 'package:dimpos_store/features/product/ui/widgets/product_detail_dialog.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/exception.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Nếu mất mạng thì vẫn add sản phẩm bình thường, nhưng khi refresh lại trang thì mới mất
class ProductItemList extends ConsumerWidget {
  const ProductItemList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    final bool isLandscape = SizeConfig.isLandscape();

    // Dummy list length — replace with your real product list length
    final productList =
        ref.watch(menuViewModelProvider).value?.productsListWithCategory;
    final isExpanded = ref.watch(sidebarStateProvider);

    // Calculate desired item dimensions based on device type
    double desiredHeight;
    int crossAxisCount;

    switch (SizeConfig.getDeviceType()) {
      case DeviceType.mobile:
        crossAxisCount = 2;
        desiredHeight = 220.h; // Your original height
        break;
      case DeviceType.tablet:
        crossAxisCount = isLandscape ? 4 : 3;
        desiredHeight = isLandscape ? 360.h : 260.h;
        break;
      default:
        crossAxisCount = 4; // More items per row on desktop
        desiredHeight = 380.h;
        break;
    }

    // Calculate available width for each grid item (accounting for spacing)
    final horizontalSpacing =
        5.w * (crossAxisCount - 1); // Total spacing between items
    final availableWidth = SizeConfig.screenWidth -
        horizontalSpacing -
        (16.w); // Subtracting padding
    final itemWidth = availableWidth / crossAxisCount;

    // Calculate the aspect ratio based on desired dimensions
    // childAspectRatio = width / height
    final childAspectRatio = (itemWidth / desiredHeight);

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildProductItem(
            context,
            ref,
            isExpanded: isExpanded,
            productId: productList?[index].id ?? '',
            name: productList?[index].name ?? '',
            price: (productList?[index].productVariants != null &&
                    productList![index].productVariants!.isNotEmpty)
                ? productList[index]
                    .productVariants!
                    .map((variant) => variant.price)
                    .reduce((value, element) =>
                        value < element ? value : element) // Minimum price
                : productList?[index].price,
            image: productList?[index].imageUrl,
            description: productList?[index].description,
          ),
          childCount: (productList?.length ??
              0), // Replace with your actual product count
        ),
      ),
    );
  }
}

Widget _buildProductItem(
  BuildContext context,
  WidgetRef ref, {
  required String productId,
  required String name,
  bool isExpanded = false,
  double? price,
  String? description,
  String? image,
}) {
  final spaceBetweenComponents = 20.h; // Space between components
  final isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
  final isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
  final isLandscape = SizeConfig.getOrientation() == Orientation.landscape;
  final titleFontSize = isMobile ? 18.sp : 20.sp;
  final titleFontWeight = isMobile
      ? FontWeight.w500
      : FontWeight.w600; // Adjust font weight based on device type
  final priceFontSize =
      isMobile ? 16.sp : 16.sp; // Adjust font size based on device type
  final priceFontWeight = isMobile
      ? FontWeight.w500
      : FontWeight.w500; // Adjust font weight based on device type
  final addToCartIconSize =
      isMobile ? 30.w : 35.w; // Adjust icon size based on device type
  final addToCartBackgroundSize =
      isMobile ? 30.w : 35.w; // Adjust background size based on device type

  final cartState = ref.watch(cartViewModelProvider);
  return cartState.when(
    data: (state) {
      return InkWell(
        onTap: () {
          // Handle item tap
          _showProductDetailDialog(
            context,
            productId: productId,
            ref: ref,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(15.w),
            boxShadow: [context.boxShadow],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageSize = constraints.maxHeight *
                  ((isTablet && isLandscape) ? 0.4 : 0.5);
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expanded(
                  //   flex: 7,
                  //   child: SizedBox(
                  //     width: double.infinity,
                  //     child: ClipRRect(
                  //       borderRadius: BorderRadius.circular(8),
                  //       child: FadeInImage.assetNetwork(
                  //         placeholder: Assets.imageNotFound,
                  //         image: image ?? '',
                  //         fit: BoxFit.cover,
                  //         imageErrorBuilder: (context, error, stackTrace) {
                  //           return Image.asset(
                  //             Assets.imageNotFound,
                  //             fit: BoxFit.cover,
                  //           );
                  //         },
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Center(
                    child: SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: FadeInImage.assetNetwork(
                          placeholder: Assets.imageNotFound,
                          image: image ?? '',
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              Assets.imageNotFound,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spaceBetweenComponents),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: context.titleMedium.copyWith(
                            color: context.onSurfaceColor,
                            fontSize: titleFontSize,
                            fontWeight: titleFontWeight,
                            height: 1.2,
                          ),
                          maxLines: isExpanded ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              price?.currency ?? '',
                              style: context.bodySmall.copyWith(
                                color: context.componentNameTextDarkColor,
                                fontSize: priceFontSize,
                                fontWeight: priceFontWeight,
                              ),
                            ),
                            InkWell(
                              onTap: cartState.value?.isUpdatingCart == true
                                  ? null
                                  : () {
                                      _showProductDetailDialog(
                                        context,
                                        productId: productId,
                                        ref: ref,
                                      );
                                    },
                              child: Container(
                                width: addToCartBackgroundSize,
                                height: addToCartBackgroundSize,
                                decoration: BoxDecoration(
                                  color: AppColors.rambutan100,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: context.primaryColor),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: addToCartIconSize,
                                  color: AppColors.neutral0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   height: titleFontHeight,
                  //   child: Text(
                  //     name,
                  //     style: context.titleMedium.copyWith(
                  //       color: context.onSurfaceColor,
                  //       fontSize: titleFontSize,
                  //       fontWeight: titleFontWeight,
                  //       height: 1.2, // Setting a consistent line height
                  //     ),
                  //     maxLines: 2,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ),
                  // // SizedBox(height: 8.h),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       price?.currency ?? '',
                  //       style: context.bodySmall.copyWith(
                  //         color: context.componentNameTextDarkColor,
                  //         fontSize: priceFontSize,
                  //         fontWeight: priceFontWeight,
                  //       ),
                  //     ),
                  //     InkWell(
                  //       onTap: cartState.value?.isUpdatingCart == true
                  //           ? null
                  //           : () {
                  //               _showProductDetailDialog(
                  //                 context,
                  //                 productId: productId,
                  //                 ref: ref,
                  //               );
                  //             },
                  //       child: Container(
                  //         width: addToCartBackgroundSize,
                  //         height: addToCartBackgroundSize,
                  //         decoration: BoxDecoration(
                  //           color: AppColors.rambutan100,
                  //           shape: BoxShape.circle,
                  //           border: Border.all(color: context.primaryColor),
                  //         ),
                  //         child: Icon(
                  //           Icons.add,
                  //           size: addToCartIconSize,
                  //           color: AppColors.neutral0,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              );
            },
          ),
        ),
      );
    },
    error: (error, stackTrace) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleApiError(error: error as DioException);
      });
      return Expanded(
        child: Center(
          child: Text(
            error.toString(),
            style: context.titleMedium,
          ),
        ),
      );
    },
    loading: () {
      return Expanded(
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
  );
}

void _showProductDetailDialog(
  BuildContext context, {
  required String productId,
  required WidgetRef ref,
}) {
  ref.read(menuViewModelProvider.notifier).selectProduct(productId);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const ProductDetailDialog();
    },
  );
}
