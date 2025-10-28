import 'package:dimpos_store/utils/utils.dart';

extension DateTimeExtension on DateTime {
  String get formatDate => Utils.formatVietnameseDate(this);
  String get formatDateInShort => Utils.formatVietnameseDateInShort(this);
  String get formatTime => Utils.formatVietnameseTime(this);
}
