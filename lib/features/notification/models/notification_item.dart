import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_item.freezed.dart';
part 'notification_item.g.dart';

@freezed
class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    required int type,
    required String message,
    required DateTime createdDate,
    DateTime? lastModifiedDate,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
}
