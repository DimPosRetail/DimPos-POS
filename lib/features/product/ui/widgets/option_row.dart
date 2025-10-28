import 'package:dimpos_store/enums/modifier_group_selected_type.dart';
import 'package:dimpos_store/extensions/build_context_extension.dart';
import 'package:dimpos_store/extensions/size_config_extension.dart';
import 'package:dimpos_store/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OptionRow extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool isRequired;
  final String? price;
  final VoidCallback onTap;
  final int? selectedType;
  final int? quantity;
  final Function(int)? onQuantityChanged;
  final bool showQuantityInput;

  const OptionRow({
    super.key,
    required this.label,
    required this.isSelected,
    this.isRequired = false,
    this.price,
    this.quantity,
    this.onQuantityChanged,
    this.showQuantityInput = false,
    required this.onTap,
    this.selectedType,
  });

  @override
  State<OptionRow> createState() => _OptionRowState();
}

class _OptionRowState extends State<OptionRow> {
  late TextEditingController _quantityController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _quantityController =
        TextEditingController(text: widget.quantity?.toString() ?? '1');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(OptionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity) {
      _quantityController.text = widget.quantity?.toString() ?? '1';
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity >= 1 && newQuantity <= 99) {
      _quantityController.text = newQuantity.toString();
      widget.onQuantityChanged?.call(newQuantity);
    }
  }

  Widget _buildQuantityControls() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              final currentQuantity =
                  int.tryParse(_quantityController.text) ?? 1;
              if (currentQuantity > 1) {
                _updateQuantity(currentQuantity - 1);
              }
            },
            child: Container(
              width: 32.w,
              height: 32.h,
              alignment: Alignment.center,
              child: Icon(
                Icons.remove,
                size: 16.w,
                color: context.onSurfaceColor,
              ),
            ),
          ),
          Container(
            width: 40.w,
            height: 32.h,
            alignment: Alignment.center,
            child: TextFormField(
              controller: _quantityController,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              style: context.bodyMedium.copyWith(
                fontSize: 14.sp,
                color: context.onSurfaceColor,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onFieldSubmitted: (value) {
                final newQuantity = int.tryParse(value) ?? 1;
                final clampedQuantity = newQuantity.clamp(1, 99);
                _updateQuantity(clampedQuantity);
                _focusNode.unfocus();
              },
              onTapOutside: (event) {
                final newQuantity = int.tryParse(_quantityController.text) ?? 1;
                final clampedQuantity = newQuantity.clamp(1, 99);
                _updateQuantity(clampedQuantity);
                _focusNode.unfocus();
              },
            ),
          ),
          InkWell(
            onTap: () {
              final currentQuantity =
                  int.tryParse(_quantityController.text) ?? 1;
              if (currentQuantity < 99) {
                _updateQuantity(currentQuantity + 1);
              }
            },
            child: Container(
              width: 32.w,
              height: 32.h,
              alignment: Alignment.center,
              child: Icon(
                Icons.add,
                size: 16.w,
                color: context.onSurfaceColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Row(
      children: [
        Expanded(
          child: Text(
            widget.label,
            style: context.bodyMedium.copyWith(
              color: context.onSurfaceColor,
              fontSize: 14.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.showQuantityInput && widget.isSelected)
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: _buildQuantityControls(),
          ),
        if (widget.price != null && widget.price!.isNotEmpty)
          Text(
            widget.price!,
            style: context.bodyMedium.copyWith(
              color: context.onSurfaceColor,
              fontSize: 14.sp,
            ),
          ),
      ],
    );

    if (widget.isRequired ||
        widget.selectedType == ModifierGroupSelectedType.Single.index) {
      return RadioListTile<bool>(
        value: true,
        groupValue: widget.isSelected ? true : null,
        onChanged: (_) => widget.onTap(),
        title: titleWidget,
        contentPadding: const EdgeInsets.all(0),
        dense: true,
        activeColor: AppColors.rambutan100,
        controlAffinity: ListTileControlAffinity.leading,
      );
    } else {
      return CheckboxListTile(
        value: widget.isSelected,
        onChanged: (_) => widget.onTap(),
        title: titleWidget,
        contentPadding: const EdgeInsets.all(0),
        dense: true,
        activeColor: AppColors.rambutan100,
        checkColor: AppColors.neutral0,
        controlAffinity: ListTileControlAffinity.leading,
      );
    }
  }
}
