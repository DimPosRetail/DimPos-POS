import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/currency_extension.dart';
import 'package:dimpos_store/extensions/iterable_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/extensions/string_extension.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem extends ConsumerWidget {
  final String name;
  final String? description;
  final String? modifierOptionDescription;
  final List<String>? extraDescriptions;
  final double price;
  final String? imageUrl;
  final int quantity;
  final void Function(int) onUpdate;
  final Function() onTap;
  const CartItem({
    super.key,
    required this.name,
    this.description,
    this.modifierOptionDescription,
    this.extraDescriptions,
    required this.price,
    this.imageUrl,
    required this.onUpdate,

    // required this.onQuantityChanged,
    required this.quantity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;

    final titleFontSize = isMobile ? 16.sp : 18.sp;
    final titleFontColor = context.componentNameTextDarkColor;
    final titleFontWeight = isMobile ? FontWeight.w600 : FontWeight.w500;
    final noteFontSize = isMobile ? 10.sp : 12.sp;
    final noteFontColor = context.componentNameTextDarkColor;
    final noteFontWeight = isMobile ? FontWeight.w400 : FontWeight.w400;
    final priceFontSize = isMobile ? 14.sp : 16.sp;
    final priceFontColor = AppColors.rambutan100;
    final priceFontWeight = isMobile ? FontWeight.w400 : FontWeight.w400;

    final imageSizeWidth = 60.w;
    final imageSizeHeight = 60.h;
    final image = imageUrl.isNullOrEmpty
        ? Image.asset(
            Assets.imageNotFound,
            height: imageSizeHeight,
            width: imageSizeWidth,
            fit: BoxFit.cover,
          )
        : Image.network(
            imageUrl!,
            width: imageSizeWidth,
            height: imageSizeHeight,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: imageSizeWidth,
                height: imageSizeHeight,
                color: Colors.grey[200],
                child:
                    const Icon(Icons.image_not_supported, color: Colors.grey),
              );
            },
          );

    final iconSize = isMobile ? 11.w : 20.w;
    return Card(
      elevation: 0,
      color: context.containerColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          children: [
            Row(
              children: [
                // Product Image
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(8),
                //   child: image,
                // ),
                SizedBox(width: 12.w),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: context.titleSmall.copyWith(
                          color: titleFontColor,
                          fontSize: titleFontSize,
                          fontWeight: titleFontWeight,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (description != null)
                        Text(
                          '• ${description!}',
                          style: context.labelSmall.copyWith(
                            color: noteFontColor,
                            fontSize: noteFontSize,
                            fontWeight: noteFontWeight,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (modifierOptionDescription != null)
                        Text(
                          '• ${modifierOptionDescription!}',
                          style: context.labelSmall.copyWith(
                            color: noteFontColor,
                            fontSize: noteFontSize,
                            fontWeight: noteFontWeight,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (extraDescriptions.isNotNullOrEmpty)
                        ...extraDescriptions!
                            .map(
                              (desc) => Text(
                                '+ $desc',
                                style: context.labelSmall.copyWith(
                                  color: noteFontColor,
                                  fontSize: noteFontSize,
                                  fontWeight: noteFontWeight,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                      SizedBox(height: 4.h),
                      Text(
                        price.currency,
                        style: context.bodyMedium.copyWith(
                          color: priceFontColor,
                          fontSize: priceFontSize,
                          fontWeight: priceFontWeight,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Column(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   crossAxisAlignment: CrossAxisAlignment.end,
                //   spacing: 15.h,
                //   children: [
                //     InkWell(
                //       onTap: onTap,
                //       hoverColor: Colors.transparent,
                //       child: Icon(
                //         Icons.delete,
                //         color: context.primaryColor,
                //         size: 20.w,
                //       ),
                //     ),
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       spacing: 8.w,
                //       children: [
                //         _iconButton(
                //           context: context,
                //           onTap: () {
                //             onUpdate(quantity - 1);
                //           },
                //           icon: Icons.remove,
                //           bgColor: context.surfaceColor,
                //           iconColor: context.onSurfaceColor,
                //           iconSize: iconSize,
                //         ),
                //         // Quantity
                //         Padding(
                //           padding: EdgeInsets.symmetric(horizontal: 8.w),
                //           child: Text(
                //             quantity.toString(),
                //             style: context.bodyMedium.copyWith(
                //               color: context.onSurfaceColor,
                //               fontSize: 16.sp,
                //             ),
                //           ),
                //         ), // Increase Button
                //         _iconButton(
                //           context: context,
                //           onTap: () {
                //             onUpdate(quantity + 1);
                //           },
                //           icon: Icons.add,
                //           bgColor: context.onSurfaceColor,
                //           iconColor: context.surfaceColor,
                //           iconSize: iconSize,
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 8.h,
              ),
              child: Divider(
                height: 1,
                color: context.onSurfaceColor.withOpacity(0.1),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 15.h,
              children: [
                InkWell(
                  onTap: onTap,
                  hoverColor: Colors.transparent,
                  child: Icon(
                    Icons.delete_outline_sharp,
                    color: context.componentNameTextColor,
                    size: 20.w,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 12.w,
                  children: [
                    _iconButton(
                      context: context,
                      onTap: () {
                        onUpdate(quantity - 1);
                      },
                      icon: Icons.remove,
                      bgColor: context.surfaceColor,
                      iconColor: context.onSurfaceColor,
                      iconSize: iconSize,
                      isEnabled: quantity > 1, // Add minimum quantity check
                    ),
                    // Quantity Display
                    Container(
                      constraints: BoxConstraints(minWidth: 40.w),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: context.surfaceColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.w),
                        border: Border.all(
                          color: context.onSurfaceColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          quantity.toString(),
                          style: context.bodyMedium.copyWith(
                            color: context.onSurfaceColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    // Increase Button
                    _iconButton(
                      context: context,
                      onTap: () {
                        onUpdate(quantity + 1);
                      },
                      icon: Icons.add,
                      bgColor: AppColors.rambutan100,
                      iconColor: context.surfaceColor,
                      iconSize: iconSize,
                      isEnabled: true,
                    ),
                  ],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   spacing: 8.w,
                //   children: [
                //     _iconButton(
                //       context: context,
                //       onTap: () {
                //         onUpdate(quantity - 1);
                //       },
                //       icon: Icons.remove,
                //       bgColor: context.surfaceColor,
                //       iconColor: context.onSurfaceColor,
                //       iconSize: iconSize,
                //     ),
                //     // Quantity
                //     Padding(
                //       padding: EdgeInsets.symmetric(horizontal: 8.w),
                //       child: Text(
                //         quantity.toString(),
                //         style: context.bodyMedium.copyWith(
                //           color: context.onSurfaceColor,
                //           fontSize: 16.sp,
                //         ),
                //       ),
                //     ), // Increase Button
                //     _iconButton(
                //       context: context,
                //       onTap: () {
                //         onUpdate(quantity + 1);
                //       },
                //       icon: Icons.add,
                //       bgColor: context.onSurfaceColor,
                //       iconColor: context.surfaceColor,
                //       iconSize: iconSize,
                //     ),
                //   ],
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _iconButton({
  required IconData icon,
  required VoidCallback onTap,
  required Color bgColor,
  required Color iconColor,
  required double iconSize,
  required BuildContext context,
  bool isEnabled = true,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(12.w),
      splashColor: iconColor.withOpacity(0.2),
      highlightColor: iconColor.withOpacity(0.1),
      child: Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: isEnabled ? bgColor : bgColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(
            color: context.onSurfaceColor.withOpacity(isEnabled ? 0.2 : 0.1),
            width: 1.5,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: bgColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: iconSize,
          fill: 1,
          color: isEnabled ? iconColor : iconColor.withOpacity(0.4),
        ),
      ),
    ),
  );
}

// Widget _iconButton({
//   required IconData icon,
//   required VoidCallback onTap,
//   required Color bgColor,
//   required Color iconColor,
//   required double iconSize,
//   required BuildContext context,
// }) {
//   return InkWell(
//     onTap: onTap,
//     hoverColor: Colors.transparent,
//     child: Container(
//       width: 18.w,
//       height: 18.h,
//       decoration: BoxDecoration(
//         color: bgColor,
//         shape: BoxShape.circle,
//         border: Border.all(color: context.onSurfaceColor),
//       ),
//       child: Icon(icon, size: iconSize, color: iconColor),
//     ),
//   );
// }
