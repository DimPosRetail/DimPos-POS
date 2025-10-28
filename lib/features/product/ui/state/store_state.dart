import 'package:dimpos_store/features/product/models/store.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_state.freezed.dart';
part 'store_state.g.dart';

@freezed
class StoreState with _$StoreState {
  const factory StoreState({
    Store? storeInfo,
  }) = _StoreState;

  factory StoreState.fromJson(Map<String, dynamic> json) =>
      _$StoreStateFromJson(json);
}
