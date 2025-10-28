// import 'dart:async'; // StreamController
// import 'package:flutter/foundation.dart' show kIsWeb; // Kiểm tra nền tảng Web
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod Provider
// import 'package:connectivity_plus/connectivity_plus.dart'; // Cho mobile

// // Chỉ import nếu đang build cho Web
// // Bọc bằng `kIsWeb` hoặc đặt trong block if (kIsWeb) {...}
// import 'dart:html' as html; // Cho Web: kiểm tra kết nối & lắng onOnline/offline

// final isOnlineProvider = StreamProvider<bool>((ref) async* {
//   if (kIsWeb) {
//     // Web: Dùng `dart:html`
//     yield html.window.navigator.onLine ?? false;

//     final controller = StreamController<bool>();

//     html.window.onOnline.listen((_) => controller.add(true));
//     html.window.onOffline.listen((_) => controller.add(false));

//     yield* controller.stream;
//   } else {
//     // Mobile: Dùng `connectivity_plus`
//     final connectivity = Connectivity();
//     final initial = await connectivity.checkConnectivity();
//     yield initial != ConnectivityResult.none;

//     await for (final result in connectivity.onConnectivityChanged) {
//       yield result != ConnectivityResult.none;
//     }
//   }
// });
