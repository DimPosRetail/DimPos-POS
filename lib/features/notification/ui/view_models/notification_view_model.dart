import 'package:dimpos_store/features/notification/repositories/notification_repository.dart';
import 'package:dimpos_store/features/notification/ui/state/notification_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_view_model.g.dart';

@Riverpod(keepAlive: true)
class NotificationViewModel extends _$NotificationViewModel {
  @override
  FutureOr<NotificationState> build() async {
    return const NotificationState();
  }

  Future<void> fetchNotifications() async {
    // Remove the early return check - always allow fetching
    // if (state.isLoading) return;

    try {
      // Always set loading state first
      state = const AsyncValue.loading();

      final repository = ref.read(notificationRepositoryProvider);

      // Fetch first page of notifications
      final response = await repository.getNotifications(
        page: 1,
        size: 4,
        sortBy: 'isRead',
        isAsc: true,
      );

      if (response != null) {
        final hasMoreData = (response.page ?? 0) < (response.totalPages ?? 0);
        state = AsyncValue.data(NotificationState(
          notifications: response.items ?? [],
          currentPage: response.page ?? 1,
          pageSize: response.size ?? 4,
          totalNotifications: response.total ?? 0,
          hasMoreData: hasMoreData,
          isLoadingMore: false,
        ));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadMoreNotifications() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        !currentState.hasMoreData) {
      return;
    }

    try {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

      final repository = ref.read(notificationRepositoryProvider);
      final nextPage = currentState.currentPage + 1;
      final response = await repository.getNotifications(
        page: nextPage,
        size: currentState.pageSize,
        sortBy: 'isRead',
        isAsc: true,
      );

      if (response != null && response.items != null) {
        final hasMoreData = nextPage < (response.totalPages ?? 0);
        final updatedNotifications = [
          ...currentState.notifications,
          ...response.items!,
        ];
        state = AsyncValue.data(NotificationState(
          notifications: updatedNotifications,
          currentPage: nextPage,
          pageSize: currentState.pageSize,
          totalNotifications: response.total ?? 0,
          hasMoreData: hasMoreData,
          isLoadingMore: false,
        ));
      } else {
        state = AsyncValue.data(currentState.copyWith(
          isLoadingMore: false,
          hasMoreData: false,
        ));
      }
    } catch (error) {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.markNotificationAsRead();

      final currentState = state.value;
      if (currentState != null) {
        final response = await repository.getNotifications(
          page: 1,
          size: 4,
          sortBy: 'isRead',
          isAsc: true,
        );

        if (response != null) {
          final hasMoreData = (response.page ?? 0) < (response.totalPages ?? 0);
          state = AsyncValue.data(NotificationState(
            notifications: response.items ?? [],
            currentPage: response.page ?? 1,
            pageSize: response.size ?? 4,
            totalNotifications: response.total ?? 0,
            hasMoreData: hasMoreData,
            isLoadingMore: false,
          ));
        }
      }
    } catch (error) {
      print('Error marking notifications as read: $error');
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.deleteNotifications();
      state = AsyncValue.data(const NotificationState());
    } catch (error) {
      print('Error deleting notifications: $error');
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }
}
