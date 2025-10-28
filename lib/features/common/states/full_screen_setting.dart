import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'full_screen_setting.g.dart';

@Riverpod(keepAlive: true)
class FullScreenSetting extends _$FullScreenSetting {
  @override
  bool build() {
    return false; // Mặc định chưa fullscreen
  }

  void enterFullScreen() {
    state = true;
  }

  void exitFullScreen() {
    state = false;
  }

  void toggle() {
    state = !state;
  }
}
