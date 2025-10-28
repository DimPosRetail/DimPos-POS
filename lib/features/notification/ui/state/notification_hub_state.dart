import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_hub_state.freezed.dart';
part 'notification_hub_state.g.dart';

@freezed
class NotificationHubState with _$NotificationHubState {
  const factory NotificationHubState({
    @Default(0) int unReadNotifications,
    @Default(false) bool isConnected,
  }) = _NotificationHubState;

  factory NotificationHubState.fromJson(Map<String, dynamic> json) =>
      _$NotificationHubStateFromJson(json);
}
