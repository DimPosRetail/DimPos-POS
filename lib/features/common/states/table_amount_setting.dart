import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'table_amount_setting.g.dart';

@Riverpod(keepAlive:true)
class TableAmountSetting extends _$TableAmountSetting {
  @override
  int build() {
    return 20;
  }

  void setTableAmount(int number) {
    state = number;
  }

  int getAmount() {
    return state;
  }

  void increment() {
    state++;
    setTableAmount(state);
  }

  void decrement() {
    if (state > 1) {
      state--;
      setTableAmount(state);
    }
  }
}
