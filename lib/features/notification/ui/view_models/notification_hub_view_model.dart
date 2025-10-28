import 'package:dimpos_store/constants/assets.dart';
import 'package:dimpos_store/enums/notification_type.dart';
import 'package:dimpos_store/features/notification/models/notification_response.dart';
import 'package:dimpos_store/features/notification/repositories/notification_hub_repository.dart';
import 'package:dimpos_store/features/notification/ui/state/notification_hub_state.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:toastification/toastification.dart';

part 'notification_hub_view_model.g.dart';

@Riverpod(keepAlive: true)
class NotificationHubViewModel extends _$NotificationHubViewModel {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  FutureOr<NotificationHubState> build() async {
    return NotificationHubState();
  }

  Future<void> createHubConnection(String token) async {
    state = const AsyncValue.loading();

    try {
      await ref.read(notificationHubRepositoryProvider).createHubConnection(
            token,
            _receiveNotification,
            _receiveUnreadNotifications,
          );
      state = AsyncValue.data(
        state.value!.copyWith(isConnected: true),
      );
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  void _receiveNotification(List<Object?>? parameters) {
    final notificationMessageServer = parameters![0] as Map<String, dynamic>;
    final notificationMessage =
        NotificationResponse.fromJson(notificationMessageServer);
    final currentState = state.value;
    final updatedState = currentState?.copyWith(
      unReadNotifications: notificationMessage.unReadCount,
    );
    toastification.show(
      type: notificationMessage.type == NotificationType.information.index
          ? ToastificationType.info
          : ToastificationType.warning,
      style: ToastificationStyle.flatColored,
      title: Text("Bạn có thông báo mới!"),
      description: Text(notificationMessage.message),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topRight,
    );
    _playNotificationSound();
    state = AsyncData(updatedState!);
  }

  void _receiveUnreadNotifications(List<Object?>? parameters) {
    final unReadCount = parameters![0] as int;
    final currentState = state.value;
    final updatedState = currentState?.copyWith(
      unReadNotifications: unReadCount,
    );
    state = AsyncData(updatedState!);
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.setAsset(Assets.notificationSound);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }

  Future<void> stopHubConnection() async {
    state = AsyncValue.data(
      state.value!.copyWith(isConnected: false),
    );
    await ref.read(notificationHubRepositoryProvider).stopHubConnection();
  }

  void setUnreadNotifications(int count) {
    final currentState = state.value;
    final updatedState = currentState?.copyWith(
      unReadNotifications: count,
    );
    state = AsyncData(updatedState!);
  }
}
