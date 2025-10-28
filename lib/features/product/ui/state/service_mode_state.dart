import 'package:dimpos_store/features/common/models/display_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_mode_state.freezed.dart';
part 'service_mode_state.g.dart';

@freezed
class ServiceModeState with _$ServiceModeState {
  const factory ServiceModeState({
    @Default([]) List<DisplayItem> modesOfService,
    // @Default(null) int? selectedModesOfService,
  }) = _ServiceModeState;

  factory ServiceModeState.fromJson(Map<String, dynamic> json) =>
      _$ServiceModeStateFromJson(json);
}
