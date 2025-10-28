import 'package:dimpos_store/features/notification/models/notification_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_state.freezed.dart';
part 'notification_state.g.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default([]) List<NotificationMessage> notifications,
    @Default(1) int currentPage,
    @Default(4) int pageSize,
    @Default(0) int totalNotifications,
    @Default(true) bool hasMoreData,
    @Default(false) bool isLoadingMore,
  }) = _NotificationState;

  factory NotificationState.fromJson(Map<String, dynamic> json) =>
      _$NotificationStateFromJson(json);
}
