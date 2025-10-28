import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/constants/language.dart';
import 'package:dimpos_store/enums/device_type.dart';
import 'package:dimpos_store/enums/mode_of_service.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/iterable_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/extensions/string_extension.dart';
import 'package:dimpos_store/features/common/ui/widgets/header.dart';
import 'package:dimpos_store/features/common/ui/widgets/show_error_dialog.dart';
import 'package:dimpos_store/features/order/ui/view_models/order_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/cart_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/financial_shift_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/menu_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/promotion_view_model.dart';
import 'package:dimpos_store/features/product/ui/view_models/table_view_model.dart';
import 'package:dimpos_store/features/product/ui/widgets/cart_item.dart';
import 'package:dimpos_store/features/product/ui/widgets/category_item_list.dart';
import 'package:dimpos_store/features/product/ui/widgets/membership_dialog.dart';
import 'package:dimpos_store/features/product/ui/widgets/order_badge.dart';
import 'package:dimpos_store/features/product/ui/widgets/payment_method_dialog.dart';
import 'package:dimpos_store/features/product/ui/widgets/price_billing.dart';
import 'package:dimpos_store/features/product/ui/widgets/product_detail_dialog.dart';
import 'package:dimpos_store/features/product/ui/widgets/product_item_list.dart';
import 'package:dimpos_store/features/product/ui/widgets/promotion_dialog.dart';
import 'package:dimpos_store/features/product/ui/widgets/service_mode_dialog.dart';
import 'package:dimpos_store/features/product/ui/widgets/sticky_header.dart';
import 'package:dimpos_store/features/product/ui/widgets/table_dialog.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:dimpos_store/utils/exception.dart';
import 'package:dimpos_store/utils/logger_config.dart';
import 'package:dimpos_store/utils/measure_text_width.dart';
import 'package:dimpos_store/utils/size_config.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    // Schedule the dialog to open after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartViewModel = ref.read(cartViewModelProvider);
      final chosenCart =
          cartViewModel.value?.carts?[cartViewModel.value!.selectedCartIndex];

      _showTableDialog(
        context,
        takeNumberDineIn: chosenCart?.takeNumberDineIn ?? 0,
      );
    });
  }

  @override
  void dispose() {
    // _subscription.close();
    _reasonController.dispose();
    _cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
    final isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
    final isDesktop = SizeConfig.getDeviceType() == DeviceType.desktop;
    final isLandscape = SizeConfig.isLandscape();

    // final isOnlineAsync = ref.watch(isOnlineProvider);
    // if (isOnlineAsync.isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    // if (isOnlineAsync.hasError || isOnlineAsync.value == null) {
    //   return ShowErrorDialog(
    //     errorMessage: "Đã có mạng xảy ra",
    //   );
    // }
    final isLoading = ref.watch(financialShiftViewModelProvider).isLoading;
    final isShiftOpen =
        ref.watch(financialShiftViewModelProvider).value?.isShiftOpen;
    return Stack(
      children: [
        Row(
          children: [
            _buildMainContent(context, isMobile, ref),
            if (isDesktop || (isTablet && isLandscape))
              _buildCartView(
                context,
                ref,
              ),
          ],
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
}

Widget _buildMainContent(
  BuildContext context,
  bool isMobile,
  WidgetRef ref,
) {
  final menuState = ref.watch(menuViewModelProvider);

  final isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
  // providerLogger.d(menuState.value!.modifierGroupWithProduct);
  return menuState.when(
    data: (state) {
      return Flexible(
        child: CustomScrollView(
          physics:
              const BouncingScrollPhysics(), // hoặc ClampingScrollPhysics()
          slivers: [
            // Non-sticky header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    // Header
                    Header(
                      isMobile: isMobile,
                    ),
                    // Title
                    Padding(
                      padding: EdgeInsets.only(top: 30.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Danh mục",
                            style: context.titleMedium.copyWith(
                              fontSize: 24.sp,
                              color: context.onSurfaceColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Combined sticky header with both Category and Search
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                minHeight: 80.h,
                maxHeight: 80.h,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isShrunk = constraints.maxHeight <= 180.h;
                    return Container(
                      color: context.containerColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Category list with flexible height
                          Flexible(
                            child: SizedBox(
                              height: 65.h,
                              // isShrunk ? 65.h : 150.h,
                              child: CategoryItemList(
                                isShrunk: isShrunk,
                              ),
                            ),
                          ),
                          // Search bar with consistent height
                          // Padding(
                          //   padding: EdgeInsets.symmetric(
                          //     horizontal: 20.w,
                          //     vertical: isShrunk ? 10.h : 13.h,
                          //   ),
                          //   child: const CustomSearchFilterBar(
                          //     isMenuScreen: true,
                          //   ),
                          // ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Scrollable product grid
            const ProductItemList(),

            SliverFillRemaining(
              hasScrollBody: false,
              child: SizedBox(
                height: 20.h,
              ),
            ),
          ],
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

Widget _buildCartView(BuildContext context, WidgetRef ref) {
  final isMobile = SizeConfig.getDeviceType() == DeviceType.mobile;
  final isTablet = SizeConfig.getDeviceType() == DeviceType.tablet;
  final isLandscape = SizeConfig.isLandscape();

  final spacingBetweenComponentHorizonal = 16.h;

  final cartWidth = (isTablet && isLandscape) ? 280.w: 390.w;
  final cartHeight = 50.h;
  final cartPaddingWidth = 20.w;
  final clearCartButtonWidth = 50.w;
  final clearCartIconWidth = 25.w;
  final clearCartButtonPadding = 8.w;

  //1. Kiểm tra xem cart đã có table sẵn chưa.
  final cartViewModel = ref.watch(cartViewModelProvider);
  final tableViewModel = ref.watch(tableViewModelProvider);
  final existingTableNumbers =
      ref.watch(financialShiftViewModelProvider).value?.takedTableNumber;

  if (tableViewModel.isLoading || cartViewModel.isLoading) {
    return Container(
      width: cartWidth,
      // padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
      padding: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [context.boxShadow],
      ),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: 50.w,
              height: 50.h,
              child: CircularProgressIndicator(
                color: context.primaryColor,
              ),
            ),
          )
        ],
      ),
    );
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

  return Stack(
    children: [
      Container(
        width: cartWidth,
        // padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
        padding: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          boxShadow: [context.boxShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(color: context.containerColor),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...List.generate((currentCarts?.length ?? 0), (index) {
                    return _cartSlot(
                      context,
                      tabName: 'Giỏ ${index + 1}',
                      tabNameTextStyle: context.labelLarge.copyWith(
                        fontSize: 16.sp,
                        color: context.componentNameTextDarkColor,
                        fontWeight: FontWeight.w400,
                      ),
                      maxWidth: cartWidth,
                      isSelected: chosenCartIndex == index,
                      onCloseTap: () async {
                        await ref
                            .read(cartViewModelProvider.notifier)
                            .removeCart(index);
                        _showTableDialog(context,
                            takeNumberDineIn:
                                chosenCart?.takeNumberDineIn ?? 0);
                      },
                      onClickTab: () async {
                        await Navigator.of(context).maybePop();
                        if (!context.mounted) return;
                        ref
                            .read(cartViewModelProvider.notifier)
                            .setSelectedCart(index);
                        _showTableDialog(context,
                            takeNumberDineIn:
                                chosenCart?.takeNumberDineIn ?? 0);
                      },
                      itemWidth: ((currentCarts?.length ?? 0) >= 3)
                          ? (cartWidth / (currentCarts?.length ?? 0))
                          : (cartWidth / ((currentCarts?.length ?? 0) + 0.5)),
                    );
                  }),
                  if ((currentCarts?.length ?? 0) < 3)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: clearCartButtonPadding),
                      child: IconButton(
                        icon: Icon(
                          Icons.add,
                          color: context.onSurfaceColor,
                          size: 16.sp,
                        ),
                        onPressed: () {
                          ref
                              .read(cartViewModelProvider.notifier)
                              .createNewCart();
                          _showTableDialog(context,
                              takeNumberDineIn:
                                  chosenCart?.takeNumberDineIn ?? 0);
                        },
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: spacingBetweenComponentHorizonal),
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
                      isDisabled: chosenCart?.cartItems.isNullOrEmpty == true ||
                          ref
                              .watch(financialShiftViewModelProvider)
                              .isLoading ||
                          chosenCart?.serviceMethod ==
                              ModeOfService.TakeAway.index,
                      isWarning:
                          existingTableNumbers?.isNotNullOrEmpty == true &&
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
                ],
              ),
            ),
            SizedBox(height: spacingBetweenComponentHorizonal),
            Flexible(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: cartPaddingWidth),
                children: chosenCart?.cartItems!.asMap().entries.map((entry) {
                      // final cartItemIndex = entry.key;
                      final e = entry.value;
                      final comboModifierOptionIds = e.modifierGroupItems
                          ?.where((modifier) =>
                              modifier.relatedComboProductVariantItemId != null)
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
                          providerLogger.d(
                            "Combo Modifier Option Ids: $comboModifierOptionIds",
                          );
                          _showProductDetailFromCartItemDialog(
                            context,
                            productVariantId: e.productVariantId,
                            totalPrice: e.itemSubtotalAmount,
                            quantity: e.quantity,
                            notesForItem: e.notesForItem,
                            modifierOptionIds: e.modifierGroupItems
                                    ?.map(
                                        (modifier) => modifier.modifierOptionId)
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
                            cartId: chosenCart.id,
                            cartItemId: e.id,
                            ref: ref,
                          );
                        },
                        child: CartItem(
                          name: e.productNameSnapshot,
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
                          extraDescriptions: e.extraItems
                              ?.map((extra) =>
                                  '${extra.extraProductVariantNameSnapshot} x${extra.quantity}')
                              .toList(),
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
                            try {
                              await ref
                                  .read(cartViewModelProvider.notifier)
                                  .updateCartItemToCart(
                                    cartId: chosenCart.id,
                                    cartItemId: e.id,
                                    quantity: quantity,
                                    modifierGroupItems:
                                        e.modifierGroupItems ?? [],
                                    extraProductItems: e.extraItems,
                                  );
                            } catch (e) {
                              handleApiError(error: e as DioException);
                            }
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
                isDisabled: chosenCart?.cartItems.isNullOrEmpty == true ||
                    ref.watch(promotionViewModelProvider).value?.isLoading ==
                        true,
                isWarning:
                    ref.watch(promotionViewModelProvider).value?.isWarning ==
                        true,
                onTap: chosenCart?.cartItems.isNullOrEmpty == true ||
                        ref
                                .watch(promotionViewModelProvider)
                                .value
                                ?.isLoading ==
                            true
                    ? null
                    : () {
                        ref
                            .read(promotionViewModelProvider.notifier)
                            .getPromotionRules(cartId: chosenCart!.id);
                        _showPromotionDialog(context);
                        // ref.watch(promotionPopupStateProvider.notifier).show();
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
                title:
                    (chosenCart?.customerNameSnapshot.isNotNullOrEmpty == true)
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
              price: (chosenCart?.finalTotalAmount ?? 0),
              paddingWidth: 20.w,
              isTotal: true,
            ),
            SizedBox(height: spacingBetweenComponentHorizonal),
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
                          color:
                              chosenCart?.cartItems?.isNotNullOrEmpty == true &&
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
                            !(existingTableNumbers?.isNotNullOrEmpty == true &&
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
                        color:
                            (chosenCart?.cartItems?.isNotNullOrEmpty == true &&
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
      //loading layer
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
        // tableNumberDineIn: cartTableDineIn,
      );
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

void _showPaymentDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PaymentMethodDialog();
    },
  );
}

Widget _cartSlot(
  BuildContext context, {
  required String tabName,
  required TextStyle tabNameTextStyle,
  required bool isSelected,
  required double itemWidth,
  required double maxWidth,
  required Function() onClickTab,
  required Function() onCloseTap,
}) {
  final borderRightWidth = 2.sp;
  String configTabName = truncateTextToFit(
      maxWidth: (itemWidth > (maxWidth / 3))
          ? itemWidth
          : (maxWidth / 3 - borderRightWidth),
      style: tabNameTextStyle,
      text: tabName);
  return InkWell(
    onTap: onClickTab,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: (itemWidth > (maxWidth / 3))
              ? itemWidth
              : (maxWidth / 3 - borderRightWidth),
          decoration: BoxDecoration(
            color: isSelected ? context.surfaceColor : context.containerColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                configTabName,
                style: tabNameTextStyle,
              ),
              InkWell(
                onTap: onCloseTap,
                child: Icon(Icons.close, size: 16.sp),
              ),
            ],
          ),
        ),
        if (!isSelected)
          Container(
            width: borderRightWidth,
            height: 26.sp,
            decoration: BoxDecoration(color: context.containerDarkerColor),
          ),
      ],
    ),
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
  required String cartId,
  required String cartItemId,
  String? notesForItem,
  required WidgetRef ref,
}) {
  final selectedProduct =
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
  if (selectedProduct == null) {
    ref.read(cartViewModelProvider.notifier).updateCartItemToCart(
          cartId: cartId,
          cartItemId: cartItemId,
          quantity: 0,
        );
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text("Lỗi"),
      description: Text(
          "Không tìm thấy sản phẩm trong thực đơn vui lòng bỏ sản phẩm khỏi giỏ hàng."),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topRight,
    );
    return;
  }
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const ProductDetailDialog();
    },
  );
}
