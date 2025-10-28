import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_response.freezed.dart';
part 'notification_response.g.dart';

@freezed
class NotificationResponse with _$NotificationResponse {
  const factory NotificationResponse({
    required String message,
    required int type,
    required int unReadCount,
  }) = _NotificationResponse;

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
}
