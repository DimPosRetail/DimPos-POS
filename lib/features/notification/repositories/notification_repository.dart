import 'package:dimpos_store/enums/api_url.dart';
import 'package:dimpos_store/features/common/models/base_response.dart';
import 'package:dimpos_store/features/common/models/paging_response.dart';
import 'package:dimpos_store/features/notification/models/notification_message.dart';
import 'package:dimpos_store/utils/request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_repository.g.dart';

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepository();
}

class NotificationRepository {
  const NotificationRepository();

  Future<PagingResponse<NotificationMessage>?> getNotifications({
    int page = 1,
    int size = 4,
    String sortBy = 'isRead',
    bool isAsc = true,
  }) async {
    final response = await apiClient.getClient(ApiUrl.notification).get(
          '/notifications',
          queryParameters: convertToQueryParams({
            'page': page,
            'size': size,
            'sortBy': sortBy,
            'isAsc': isAsc,
          }),
        );
    final notificationResponse =
        BaseResponse<PagingResponse<NotificationMessage>?>.fromJson(
      response.data,
      (json) => PagingResponse<NotificationMessage>.fromJson(
        json as Map<String, dynamic>,
        (item) => NotificationMessage.fromJson(item as Map<String, dynamic>),
      ),
    ).data;
    return notificationResponse;
  }

  Future<void> deleteNotifications() async {
    await apiClient.getClient(ApiUrl.notification).delete('/notifications');
  }

  Future<void> markNotificationAsRead() async {
    await apiClient.getClient(ApiUrl.notification).put(
          '/notifications/make-read',
        );
  }
}
