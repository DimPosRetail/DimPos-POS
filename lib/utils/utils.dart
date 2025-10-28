import 'package:dimpos_store/enums/store_role.dart';
import 'package:easy_localization/easy_localization.dart';

class Utils {
  Utils._();

  static DateTime getToday() {
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day);
  }

  static String formatCurrencyVND(double amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  static String formatVietnameseDate(DateTime dateTime) {
    // Ensure Vietnamese locale is used
    final dayOfWeek = DateFormat.E('vi_VN').format(dateTime); // e.g., "T2"
    final date = DateFormat("d 'Tháng' M, y", 'vi_VN')
        .format(dateTime); // "29 Tháng 5, 2025"
    return '$dayOfWeek, $date';
  }

  static String formatVietnameseDateInShort(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy', 'vi_VN').format(dateTime);
  }

  static String formatVietnameseTime(DateTime dateTime) {
    // Ensure Vietnamese locale is used
    final time = DateFormat('hh:mm a', 'vi_VN').format(dateTime); // "14:30"
    return time;
  }

  static bool isValidStoreRole(String roleStr) {
    return StoreRole.values
        .any((role) => role.toString().split('.').last == roleStr);
  }
}
