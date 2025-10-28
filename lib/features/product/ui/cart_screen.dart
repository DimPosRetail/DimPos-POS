import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/constants/language.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/enums/mode_of_service.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/iterable_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/extensions/string_extension.dart';
import 'package:dimpos_store/features/common/ui/widgets/show_error_dialog.dart';
import 'package:dimpos_store/features/order/ui/view_models/order_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/financial_shift_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/menu_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/promotion_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/table_view_model.dart';
import 'package:dimpos_store/features/product/ui/widgets/cart_item.dart';
import 'package:dimpos_store/features/product/ui/widgets/membership_dialog.dart';
import 'package:dimpos_store/features/product/ui/widgets/order_badge.dart';
import 'package:dimpos_store/features/product/ui/widgets/payment_method_dialog.dart';
import 'package:dimpos_store/features/product/ui/widgets/price_billing.dart';
import 'package:dimpos_store/features/product/ui/widgets/product_detail_dialog.dart';
import 'package:dimpos_store/features/product/ui/widgets/promotion_dialog.dart';
import 'package:dimpos_store/features/product/ui/widgets/service_mode_dialog.dart';
import 'package:dimpos_store/features/product/ui/widgets/table_dialog.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/exception.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  // bool _dialogShown = false;
  // late final ProviderSubscription<AsyncValue<bool>> _subscription;

  // void _handleConnectivityChange(BuildContext context, bool isOnline) {
  //   double sizePercentage = 0.4;
  //   final screenHeight = MediaQuery.of(context).size.height;
  //   final imageSizeWidth = 200.w;

  //   final image = Image.asset(
  //     Assets.loadingError,
  //     width: imageSizeWidth,
  //     fit: BoxFit.cover,
  //   );
  //   if (!isOnline && !_dialogShown) {
  //     _dialogShown = true;
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (_) => AlertDialog(
  //         backgroundColor: context.containerColor,
  //         content: Container(
  //           width: sizePercentage * screenHeight,
  //           height: sizePercentage * screenHeight,
  //           decoration: BoxDecoration(
  //             color: context.containerColor,
  //           ),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               Text(
  //                 "Mất kết nối",
  //                 textAlign: TextAlign.center,
  //                 style: context.titleLarge.copyWith(
  //                   color: context.componentNameTextColor,
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: 12.h,
  //               ),
  //               image,
  //               SizedBox(
  //                 height: 12.h,
  //               ),
  //               Text(
  //                 "Bạn đang offline. Vui lòng kiểm tra kết nối mạng.",
  //                 textAlign: TextAlign.center,
  //                 style: context.titleMedium.copyWith(
  //                   color: context.componentNameTextColor,
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   } else if (isOnline && _dialogShown) {
  //     Navigator.of(context, rootNavigator: true).pop();
  //     _dialogShown = false;
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();

  //   // 3. Lắng nghe trạng thái mạng
  //   _subscription = ref.listenManual<AsyncValue<bool>>(
  //     isOnlineProvider,
  //     (previous, next) {
  //       next.whenData((isOnline) {
  //         _handleConnectivityChange(context, isOnline);
  //       });
  //     },
  //   );
  // }

  // @override
  // void dispose() {
  //   _subscription.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;

    final clearCartButtonWidth = 50.w;
    final cartPaddingWidth = 0.w;
    final clearCartButtonPadding = 0.w;
    final clearCartIconWidth = 25.w;
    final cartWidth = MediaQuery.of(context).size.width;
    final cartHeight = 50.h;
    final spacingBetweenComponentHorizonal = 16.h;

    // final isOnlineAsync = ref.watch(isOnlineProvider);
    // if (isOnlineAsync.isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    // if (isOnlineAsync.hasError || isOnlineAsync.value == null) {
    //   return ShowErrorDialog(
    //     errorMessage: "Đã có mạng xảy ra",
    //   );
    // }
    //1. Kiểm tra xem cart đã có table sẵn chưa.
    final cartViewModel = ref.watch(cartViewModelProvider);
    final tableViewModel = ref.watch(tableViewModelProvider);
    final existingTableNumbers =
        ref.watch(financialShiftViewModelProvider).value?.takedTableNumber;

    if (tableViewModel.isLoading || cartViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cartViewModel.hasError || cartViewModel.value == null) {
      return ShowErrorDialog(
        errorMessage: 'Đã có lỗi xảy ra khi tải giỏ hàng',
      );
    }
    if (tableViewModel.hasError || tableViewModel.value == null) {
      return ShowErrorDialog(
        errorMessage: 'Đã có lỗi xảy ra khi tải bàn',
      );
    }

    final currentCarts = cartViewModel.value!.carts;
    final chosenCartIndex = cartViewModel.value!.selectedCartIndex;
    final chosenCart = currentCarts?[chosenCartIndex];
    final isLoading = ref.watch(financialShiftViewModelProvider).isLoading;
    final isShiftOpen =
        ref.watch(financialShiftViewModelProvider).value?.isShiftOpen;

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(20.h),
          color: context.surfaceColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Language.order.tr(),
                style: context.displayLarge.copyWith(
                  fontSize: 30.sp,
                  color: context.onSurfaceColor,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: cartPaddingWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 10.w,
                  children: [
                    Flexible(
                      child: OrderBadge(
                        title: (chosenCart?.takeNumberDineIn == null ||
                                chosenCart?.serviceMethod ==
                                    ModeOfService.TakeAway.index)
                            ? "Chọn bàn"
                            : '${Language.table.tr()} ${chosenCart?.takeNumberDineIn!.toString().padLeft(2, '0')}',
                        onTap: chosenCart?.serviceMethod ==
                                ModeOfService.TakeAway.index
                            ? null
                            : () {
                                _showTableDialog(
                                  context,
                                  takeNumberDineIn:
                                      chosenCart?.takeNumberDineIn ?? 0,
                                );
                              },
                        isDisabled:
                            chosenCart?.cartItems.isNullOrEmpty == true ||
                                ref
                                    .watch(financialShiftViewModelProvider)
                                    .isLoading ||
                                chosenCart?.serviceMethod ==
                                    ModeOfService.TakeAway.index,
                        isWarning: existingTableNumbers?.isNotNullOrEmpty ==
                                true &&
                            chosenCart?.serviceMethod ==
                                ModeOfService.DineIn.index &&
                            existingTableNumbers!
                                .contains(chosenCart?.takeNumberDineIn ?? 1),
                      ),
                    ),
                    Flexible(
                      child: OrderBadge(
                        title: (chosenCart?.serviceMethod == null)
                            ? Language.modeOfService.tr()
                            : (ModeOfService.values.firstWhereOrNull((e) {
                                return e.index == chosenCart!.serviceMethod;
                              }))!
                                .label,
                        onTap: () {
                          _showServiceModeDialog(
                            context,
                            serviceMethod: chosenCart?.serviceMethod ??
                                ModeOfService.DineIn.index,
                          );
                          // ref.watch(serviceModePopupStateProvider.notifier).show();
                        },
                        isDisabled: chosenCart?.cartItems.isNullOrEmpty == true,
                      ),
                    ),
                    // Flexible(
                    //   child: OrderBadge(
                    //     title: (chosenCart.modeOfService.isNullOrEmpty)
                    //         ? Language.modeOfService.tr()
                    //         : (ModeOfService.values.firstWhereOrNull((e) {
                    //             return e.name == chosenCart.modeOfService;
                    //           }))!
                    //             .label,
                    //     onTap: () {
                    //       _showServiceModeDialog(context);
                    //       // ref.watch(serviceModePopupStateProvider.notifier).show();
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),
              SizedBox(height: spacingBetweenComponentHorizonal),
              SizedBox(height: 8.h),
              Flexible(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: cartPaddingWidth),
                  children: chosenCart?.cartItems!.asMap().entries.map((entry) {
                        // final cartItemIndex = entry.key;
                        final e = entry.value;
                        final comboModifierOptionIds = e.modifierGroupItems
                            ?.where((modifier) =>
                                modifier.relatedComboProductVariantItemId !=
                                null)
                            .map((modifier) => MapEntry(
                                  modifier.relatedComboProductVariantItemId!,
                                  modifier.modifierOptionId,
                                ))
                            .fold<Map<String, List<String>>>({}, (map, entry) {
                          map.putIfAbsent(entry.key, () => []).add(entry.value);
                          return map;
                        });
                        return InkWell(
                          onTap: () {
                            _showProductDetailFromCartItemDialog(
                              context,
                              productVariantId: e.productVariantId,
                              totalPrice: e.itemSubtotalAmount,
                              quantity: e.quantity,
                              notesForItem: e.notesForItem,
                              modifierOptionIds: e.modifierGroupItems
                                      ?.map((modifier) =>
                                          modifier.modifierOptionId)
                                      .toList() ??
                                  [],
                              extraProductItems: e.extraItems
                                      ?.map((extra) => (
                                            extra.extraProductVariantId,
                                            extra.quantity
                                          ))
                                      .toList() ??
                                  [],
                              comboModifierOptionIds: comboModifierOptionIds,
                              cartItemId: e.id,
                              ref: ref,
                            );
                          },
                          child: CartItem(
                            name: e.productVariantNameSnapshot,
                            description: e.productNameSnapshot !=
                                    e.productVariantNameSnapshot
                                ? e.productVariantNameSnapshot
                                : null,
                            modifierOptionDescription:
                                e.modifierGroupItems.isNullOrEmpty
                                    ? null
                                    : e.modifierGroupItems
                                        ?.map((modifier) =>
                                            modifier.modifierOptionSnapshot)
                                        .join(', '),
                            price: e.itemSubtotalAmount,
                            quantity: e.quantity,
                            imageUrl: e.productImageUrlSnapshot,
                            onTap: () async {
                              try {
                                await ref
                                    .read(cartViewModelProvider.notifier)
                                    .updateCartItemToCart(
                                      cartId: chosenCart.id,
                                      cartItemId: e.id,
                                      quantity: 0,
                                      modifierGroupItems:
                                          e.modifierGroupItems ?? [],
                                    );
                              } catch (e) {
                                handleApiError(error: e as DioException);
                              }
                            },
                            onUpdate: (quantity) async {
                              await ref
                                  .read(cartViewModelProvider.notifier)
                                  .updateCartItemToCart(
                                    cartId: chosenCart.id,
                                    cartItemId: e.id,
                                    quantity: quantity,
                                    modifierGroupItems:
                                        e.modifierGroupItems ?? [],
                                  );
                              // ref
                              //     .read(cartViewModelProvider.notifier)
                              //     .updateCartItemToCart(
                              //         chosenCartIndex, cartItemIndex, quantity);
                            },
                          ),
                        );
                      }).toList() ??
                      [],
                ),
              ),
              SizedBox(height: spacingBetweenComponentHorizonal),
              Container(
                padding: EdgeInsets.symmetric(horizontal: cartPaddingWidth),
                height: isMobile ? 48.h : 48.h,
                child: OrderBadge(
                  title: chosenCart?.promotionsApplied.isNotNullOrEmpty == true
                      ? "Đang áp dụng giảm giá"
                      : "Mã giảm giá",
                  icon: Assets.discount,
                  isHavingChoosenValue:
                      chosenCart?.promotionsApplied.isNotNullOrEmpty == true,
                  onTap: () {
                    _showPromotionDialog(
                      context,
                    );
                  },
                ),
              ),
              SizedBox(
                height: 8.h,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: cartPaddingWidth),
                height: isMobile ? 48.h : 48.h,
                child: OrderBadge(
                  title: (chosenCart?.customerNameSnapshot.isNotNullOrEmpty ==
                          true)
                      ? chosenCart?.customerNameSnapshot?.toString() ??
                          "Khách hàng"
                      : "Khách hàng",
                  icon: Assets.membership,
                  isHavingChoosenValue:
                      chosenCart?.customerNameSnapshot.isNotNullOrEmpty == true,
                  onTap: () {
                    _showMemberDialog(context);
                    // ref.watch(membershipPopupStateProvider.notifier).show();
                  },
                ),
              ),
              SizedBox(height: spacingBetweenComponentHorizonal),
              PriceBilling(
                title: "Tạm Tính",
                price: chosenCart?.subtotalAmount ?? 0,
                paddingWidth: cartPaddingWidth,
              ),
              PriceBilling(
                title: "Thuế",
                price: chosenCart?.totalTaxAmount ?? 0,
                paddingWidth: cartPaddingWidth,
              ),
              PriceBilling(
                title: "Giảm giá",
                price: (chosenCart?.totalItemDiscountAmount ?? 0) +
                    (chosenCart?.orderLevelDiscountAmount ?? 0),
                paddingWidth: cartPaddingWidth,
              ),
              SizedBox(height: 8.h),
              Center(
                child: Container(
                  width: cartWidth - cartPaddingWidth * 2,
                  height: 1.h,
                  color: context.componentNameTextLightColor,
                ),
              ),
              SizedBox(height: 8.h),
              PriceBilling(
                title: "Tổng cộng",
                price: chosenCart?.finalTotalAmount ?? 0,
                isTotal: true,
              ),
              SizedBox(height: spacingBetweenComponentHorizonal),

              // PaymentMethod(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: cartPaddingWidth),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(clearCartButtonPadding),
                      child: SizedBox(
                        width: clearCartButtonWidth,
                        height: clearCartButtonWidth,
                        child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: chosenCart?.cartItems?.isNotNullOrEmpty ==
                                        true &&
                                    ref
                                            .watch(promotionViewModelProvider)
                                            .value
                                            ?.isWarning ==
                                        false
                                ? context.onSurfaceColor
                                : context.onSurfaceColor.withOpacity(0.5),
                            size: clearCartIconWidth,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: context.containerColor,
                            shape: CircleBorder(),
                          ),
                          onPressed:
                              chosenCart?.cartItems?.isNotNullOrEmpty == true &&
                                      ref
                                              .watch(promotionViewModelProvider)
                                              .value
                                              ?.isWarning ==
                                          false
                                  ? () {
                                      ref
                                          .read(cartViewModelProvider.notifier)
                                          .clearCart(chosenCartIndex);
                                    }
                                  : null,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (chosenCart?.cartItems?.isNotNullOrEmpty == true &&
                              ref
                                      .watch(promotionViewModelProvider)
                                      .value
                                      ?.isWarning ==
                                  false &&
                              !(existingTableNumbers?.isNotNullOrEmpty ==
                                      true &&
                                  chosenCart?.serviceMethod ==
                                      ModeOfService.DineIn.index &&
                                  existingTableNumbers!.contains(
                                      chosenCart?.takeNumberDineIn ?? 1)))
                          ? () {
                              // Handle payment action
                              // ref.read(paymentMethodPopupStateProvider.notifier).show();\
                              ref
                                  .read(cartViewModelProvider.notifier)
                                  .setDraftOrder(chosenCart, chosenCartIndex);
                              ref
                                  .read(orderViewModelProvider.notifier)
                                  .resetStatusSuccessPaymentForOrder();
                              _showPaymentDialog(context);
                            }
                          : null,
                      child: Container(
                        height: cartHeight,
                        width: cartWidth -
                            (clearCartButtonPadding + clearCartButtonWidth) * 2,
                        decoration: BoxDecoration(
                          color: (chosenCart?.cartItems?.isNotNullOrEmpty ==
                                      true &&
                                  ref
                                          .watch(promotionViewModelProvider)
                                          .value
                                          ?.isWarning ==
                                      false &&
                                  !(existingTableNumbers?.isNotNullOrEmpty ==
                                          true &&
                                      chosenCart?.serviceMethod ==
                                          ModeOfService.DineIn.index &&
                                      existingTableNumbers!.contains(
                                          chosenCart?.takeNumberDineIn ?? 1)))
                              ? context.primaryColor
                              : context.primaryColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(100.w),
                        ),
                        child: Center(
                          child: Text(
                            Language.payment.tr(),
                            style: context.titleMedium.copyWith(
                              color: AppColors.neutral0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (cartViewModel.value!.isUpdatingCart)
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
        if (isShiftOpen == false)
          Positioned.fill(
            child: Container(
              color: context.containerColor.withOpacity(0.6),
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      width: isMobile ? 300.w : 400.w,
                      padding: EdgeInsets.all(20.sp),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(10.sp),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Ca tài chính của bạn',
                              style: TextStyle(
                                fontSize: isMobile ? 18.sp : 20.sp,
                                fontWeight: FontWeight.bold,
                                color: context.onSurfaceColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isMobile ? 16.h : 20.h),
                            Text(
                              'Tiền mở két thực tế',
                              style: TextStyle(
                                fontSize: isMobile ? 14.sp : 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextFormField(
                              controller: _cashController,
                              style: context.bodyMedium.copyWith(
                                color: context.onSurfaceColor,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                hintText: 'Nhập tiền mở két thực tế...',
                                suffixText: '₫',
                                suffixStyle: TextStyle(
                                  color: context.onSurfaceColor,
                                  fontSize: isMobile ? 14.sp : 16.sp,
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: isMobile ? 14.sp : 16.sp,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.w),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Vui lòng nhập tiền mở két thực tế';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Vui lòng nhập số hợp lệ';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: isMobile ? 16.h : 20.h),
                            Text(
                              'Lý do chênh lệch tiền',
                              style: TextStyle(
                                fontSize: isMobile ? 14.sp : 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextFormField(
                              controller: _reasonController,
                              style: context.bodyMedium.copyWith(
                                color: context.onSurfaceColor,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Nhập lý do chênh lệch tiền...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: isMobile ? 14.sp : 16.sp,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.w),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 20.h : 24.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            final String reason =
                                                _reasonController.text.trim();
                                            final double cash = double.tryParse(
                                                    _cashController.text
                                                        .trim()) ??
                                                0.0;
                                            try {
                                              await ref
                                                  .read(
                                                      financialShiftViewModelProvider
                                                          .notifier)
                                                  .openShift(
                                                    openingCashActual: cash,
                                                    openingDifferenceReason:
                                                        reason,
                                                  );
                                              toastification.show(
                                                type:
                                                    ToastificationType.success,
                                                style: ToastificationStyle
                                                    .fillColored,
                                                title: Text("Mở ca thành công"),
                                                description: Text(
                                                    "Ca tài chính đã được mở thành công."),
                                                autoCloseDuration:
                                                    const Duration(seconds: 3),
                                                alignment: Alignment.topRight,
                                              );
                                            } catch (e) {
                                              handleApiError(
                                                  error: e as DioException);
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isLoading
                                        ? AppColors.rambutan50
                                        : AppColors.rambutan100,
                                    foregroundColor: context.surfaceColor,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 20.h,
                                      horizontal: 26.w,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.w),
                                    ),
                                  ),
                                  child: Text(
                                    'Mở ca',
                                    style: TextStyle(
                                      fontSize: isMobile ? 14.sp : 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white.withOpacity(0.8),
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
            ),
          ),
      ],
    );
  }

  void _showPromotionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PromotionDialog();
      },
    );
  }

  void _showMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MembershipDialog();
      },
    );
  }

  void _showTableDialog(
    BuildContext context, {
    required int takeNumberDineIn,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TableDialog(
          takeNumberDineIn: takeNumberDineIn,
        );
      },
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PaymentMethodDialog();
      },
    );
  }

  void _showProductDetailFromCartItemDialog(
    BuildContext context, {
    required String productVariantId,
    required double totalPrice,
    required int quantity,
    required List<String> modifierOptionIds,
    required List<(String, int)> extraProductItems,
    Map<String, List<String>>? comboModifierOptionIds,
    required String cartItemId,
    String? notesForItem,
    required WidgetRef ref,
  }) {
    ref.read(menuViewModelProvider.notifier).selectProductFromCartItem(
          productVariantId: productVariantId,
          quantity: quantity,
          totalPrice: totalPrice,
          modifierOptionIds: modifierOptionIds,
          extraProductItems: extraProductItems,
          notesForItem: notesForItem,
          cartItemId: cartItemId,
          comboModifierOptionIds: comboModifierOptionIds,
        );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const ProductDetailDialog();
      },
    );
  }

  void _showServiceModeDialog(
    BuildContext context, {
    required int serviceMethod,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ServiceModeDialog(
          serviceMethod: serviceMethod,
        );
      },
    );
  }
}
