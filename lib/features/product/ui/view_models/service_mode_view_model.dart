import 'package:dimpos_store/constants/language.dart';
import 'package:dimpos_store/enums/mode_of_service.dart';
import 'package:dimpos_store/features/common/models/display_item.dart';
import 'package:dimpos_store/features/product/ui/state/service_mode_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'service_mode_view_model.g.dart';

@Riverpod(keepAlive: true)
class ServiceModeViewModel extends _$ServiceModeViewModel {
  @override
  FutureOr<ServiceModeState> build() async {
    List<DisplayItem> modesOfService = [
      DisplayItem(
        display: Language.dineIn.tr(),
        value: ModeOfService.DineIn.index,
      ),
      DisplayItem(
        display: Language.takeAway.tr(),
        value: ModeOfService.TakeAway.index,
      ),
    ];
    return ServiceModeState(modesOfService: modesOfService);
  }

  // void setSelectedModeOfService(int index) {
  //   final modesOfService = state.value?.modesOfService ?? [];
  //   if (state.value == null) {
  //     return;
  //   }
  //   state = AsyncData(
  //     state.value!.copyWith(
  //         modesOfService: modesOfService, selectedModesOfService: index),
  //   );
  // }
}
