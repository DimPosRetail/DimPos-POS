import 'package:dimpos_store/features/product/models/tax_rate.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store.freezed.dart';
part 'store.g.dart';

@freezed
class Store with _$Store {
  const factory Store({
    required String name,
    required String address,
    required String phone,
    required String email,
    required String brandId,
    String? pictureUrl,
    String? wifiName,
    String? wifiPassword,
    String? managerName,
    TaxRate? taxRate,
  }) = _Store;
  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
}
