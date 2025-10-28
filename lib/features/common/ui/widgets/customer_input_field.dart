import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'en_VN');
  static const int _maxDigits = 15;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Lấy chuỗi chỉ chứa số
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Nếu vượt quá 15 chữ số, giữ nguyên giá trị cũ
    if (digitsOnly.length > _maxDigits) {
      return oldValue;
    }

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Định dạng lại chuỗi số
    final formatted = _formatter.format(int.parse(digitsOnly));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
