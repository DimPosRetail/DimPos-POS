import 'package:dimpos_store/utils/utils.dart';

extension CurrencyExtension on num {
  String get currency => Utils.formatCurrencyVND(toDouble());
}
