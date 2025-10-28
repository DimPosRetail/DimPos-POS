import 'package:dimpos_store/constants/language.dart';
import 'package:easy_localization/easy_localization.dart';

enum ModeOfService { DineIn, TakeAway, PreOrderPickup }

extension ModeOfServiceLabel on ModeOfService {
  String get label {
    switch (this) {
      case ModeOfService.DineIn:
        return Language.dineIn.tr();
      case ModeOfService.TakeAway:
        return Language.takeAway.tr();
      case ModeOfService.PreOrderPickup:
        return Language.preOrderPickup.tr();
    }
  }
}
