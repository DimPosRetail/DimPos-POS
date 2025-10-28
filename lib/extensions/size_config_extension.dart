import 'package:dimpos_store/utils/size_config.dart';

extension SizeConfigExtension on num {
  double get w => SizeConfig.width(toDouble());
  double get h => SizeConfig.height(toDouble());
  double get sp => SizeConfig.text(toDouble());

  // Percentage of screen width/height
  double get pw => SizeConfig.getProportionateScreenWidth(toDouble());
  double get ph => SizeConfig.getProportionateScreenHeight(toDouble());
}
