import 'package:dimpos_store/features/common/models/display_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'table_state.freezed.dart';
part 'table_state.g.dart';

@freezed
class TableState with _$TableState {
  const factory TableState({
    @Default([]) List<DisplayItem> tables,
    // @Default(null) int? selectedTable,
  }) = _TableState;

  factory TableState.fromJson(Map<String, dynamic> json) =>
      _$TableStateFromJson(json);
}
