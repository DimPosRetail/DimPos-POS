import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sidebar_state.g.dart';

@Riverpod(keepAlive: true)
class SidebarState extends _$SidebarState {
  @override
  bool build() {
    return true; // Automatically minimize
  }


  void toggle() {
    state = !state;
  }
}
