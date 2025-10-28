import 'package:freezed_annotation/freezed_annotation.dart';

part 'table_order.freezed.dart';
part 'table_order.g.dart';

@freezed
class TableOrder with _$TableOrder {
  const factory TableOrder({
    @Default([]) List<int> takedTableNumber,
  }) = _TableOrder;

  factory TableOrder.fromJson(Map<String, dynamic> json) =>
      _$TableOrderFromJson(json);
}
