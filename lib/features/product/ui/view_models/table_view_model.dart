import 'package:dimpos_store/constants/language.dart';
import 'package:dimpos_store/features/common/models/display_item.dart';
import 'package:dimpos_store/features/common/states/table_amount_setting.dart';
import 'package:dimpos_store/features/product/ui/state/table_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'table_view_model.g.dart';

@riverpod
class TableViewModel extends _$TableViewModel {
  @override
  FutureOr<TableState> build() async {
    final int tableAmount = ref.watch(tableAmountSettingProvider);
    if (tableAmount <= 0) return TableState();
    final tables = List<DisplayItem>.generate(
      tableAmount,
      (index) => DisplayItem(
        display:
            '${Language.table.tr()} ${(index + 1).toString().padLeft(2, '0')}',
        value: index + 1,
      ),
    );
    return TableState(
      tables: tables,
    );
  }

  // void setSelectedTableOption(int index) {
  //   final tables = state.value?.tables ?? [];
  //   if (state.value == null) {
  //     return;
  //   }
  //   state = AsyncData(
  //     state.value!.copyWith(
  //         tables: tables, selectedTable: index),
  //   );
  // }
}
