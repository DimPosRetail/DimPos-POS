import 'package:dimpos_store/environment/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

part 'notification_hub_repository.g.dart';

@Riverpod(keepAlive: true)
NotificationHubRepository notificationHubRepository(Ref ref) {
  return NotificationHubRepository();
}

class NotificationHubRepository {
  HubConnection? _hubConnection;
  NotificationHubRepository();

  Future<void> createHubConnection(
    String token,
    void Function(List<Object?>? parameters) receiveNotification,
    void Function(List<Object?>? parameters) receiveUnreadNotifications,
  ) async {
    _hubConnection = HubConnectionBuilder()
        .withUrl(
          '${Env.notificationHubUrl}/hubs/notification',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ),
        )
        .build();

    // Add connection state logging
    _hubConnection!.onclose(({Exception? error}) {
      debugPrint("SignalR Connection Closed: ${error?.toString()}");
    });

    _hubConnection!.onreconnecting(({Exception? error}) {
      debugPrint("SignalR Reconnecting: ${error?.toString()}");
    });

    _hubConnection!.onreconnected(({String? connectionId}) {
      debugPrint("SignalR Reconnected with ID: $connectionId");
    });

    try {
      if (_hubConnection!.state != HubConnectionState.Connected) {
        await _hubConnection!.start();
        debugPrint("SignalR Connected successfully");
      }
    } catch (e) {
      debugPrint("SignalR Connection failed: $e");
    }

    _hubConnection!.on("ReceiveNotification", receiveNotification);
    _hubConnection!
        .on("ReceiveUnreadNotifications", receiveUnreadNotifications);
  }

  Future<void> stopHubConnection() async {
    if (_hubConnection == null) return;
    await _hubConnection!
        .stop()
        .catchError((e) => {debugPrint("Notification Hub at Stop: $e")});
    _hubConnection = null;
  }
}
