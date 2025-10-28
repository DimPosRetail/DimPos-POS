import 'package:dimpos_store/enums/device_type.dart';
import 'package:flutter/widgets.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double textScaleFactor;

  // Portrait design dimensions
  static const double desktopDesignWidth = 1528.00;
  static const double desktopDesignHeight = 785.60;
  static const double tabletDesignWidth = 768.00;
  static const double tabletDesignHeight = 1024.00;
  static const double mobileDesignWidth = 375.00;
  static const double mobileDesignHeight = 812.00;

  // Landscape design dimensions
  static const double desktopDesignWidthLandscape = 1528.00;
  static const double desktopDesignHeightLandscape = 785.60;
  static const double tabletDesignWidthLandscape = 1024.00;
  static const double tabletDesignHeightLandscape = 768.00;
  static const double mobileDesignWidthLandscape = 812.00;
  static const double mobileDesignHeightLandscape = 375.00;

  static late DeviceType _deviceType;
  static late Orientation _orientation;

  static late double scaleWidth;
  static late double scaleHeight;
  static late double scaleText;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    textScaleFactor = mediaQuery.textScaleFactor;
    _orientation = mediaQuery.orientation;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _deviceType = _getDeviceType();

    double designWidth;
    double designHeight;
    double textAdjustment;

    final isLandscape = _orientation == Orientation.landscape;

    switch (_deviceType) {
      case DeviceType.mobile:
        designWidth = isLandscape ? mobileDesignWidthLandscape : mobileDesignWidth;
        designHeight = isLandscape ? mobileDesignHeightLandscape : mobileDesignHeight;
        textAdjustment = 1.0;
        break;
      case DeviceType.tablet:
        designWidth = isLandscape ? tabletDesignWidthLandscape : tabletDesignWidth;
        designHeight = isLandscape ? tabletDesignHeightLandscape : tabletDesignHeight;
        textAdjustment = 0.9;
        break;
      case DeviceType.desktop:
        designWidth = isLandscape ? desktopDesignWidthLandscape : desktopDesignWidth;
        designHeight = isLandscape ? desktopDesignHeightLandscape : desktopDesignHeight;
        textAdjustment = 0.97;
        break;
    }

    scaleWidth = screenWidth / designWidth;
    scaleHeight = screenHeight / designHeight;
    scaleText = scaleWidth * textAdjustment;

    // debugPrint('Device Type: $_deviceType');
    // debugPrint('Orientation: $_orientation');
    // debugPrint(
    //     'Screen: ${screenWidth.toStringAsFixed(2)} x ${screenHeight.toStringAsFixed(2)}');
    // debugPrint(
    //     'Scale factors - width: ${scaleWidth.toStringAsFixed(2)}, height: ${scaleHeight.toStringAsFixed(2)}, text: ${scaleText.toStringAsFixed(2)}');
  }

  static double width(double pixels) {
    return pixels * scaleWidth;
  }

  static double height(double pixels) {
    return pixels * scaleHeight;
  }

  static double text(double pixels) {
    double baseSize;
    switch (_deviceType) {
      case DeviceType.mobile:
        baseSize = pixels * 0.85;
        break;
      case DeviceType.tablet:
        baseSize = pixels * 0.9;
        break;
      case DeviceType.desktop:
        baseSize = pixels;
        break;
    }

    return baseSize * scaleText;
  }

  static double getProportionateScreenWidth(double percentage) {
    return screenWidth * (percentage / 100);
  }

  static double getProportionateScreenHeight(double percentage) {
    return screenHeight * (percentage / 100);
  }

  static DeviceType getDeviceType() {
    return _deviceType;
  }

  static Orientation getOrientation() {
    return _orientation;
  }

  static bool isLandscape() {
    return _orientation == Orientation.landscape;
  }

  static bool isPortrait() {
    return _orientation == Orientation.portrait;
  }

  static DeviceType _getDeviceType() {
    if (screenWidth < 600) {
      return DeviceType.mobile;
    } else if (screenWidth < 1100) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
}
// import 'package:dimpos_store/enums/device_type.dart';
// import 'package:flutter/widgets.dart';

// class SizeConfig {
//   static late double screenWidth;
//   static late double screenHeight;
//   static late double blockSizeHorizontal;
//   static late double blockSizeVertical;
//   static late double textScaleFactor;

//   static const double desktopDesignWidth = 1528.00;
//   static const double desktopDesignHeight = 785.60;
//   static const double tabletDesignWidth = 768.00;
//   static const double tabletDesignHeight = 1024.00;
//   static const double mobileDesignWidth = 375.00;
//   static const double mobileDesignHeight = 812.00;

//   static late DeviceType _deviceType;

//   static late double scaleWidth;
//   static late double scaleHeight;
//   static late double scaleText;

//   static void init(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     screenWidth = mediaQuery.size.width;
//     screenHeight = mediaQuery.size.height;
//     textScaleFactor = mediaQuery.textScaleFactor;

//     blockSizeHorizontal = screenWidth / 100;
//     blockSizeVertical = screenHeight / 100;

//     _deviceType = _getDeviceType();

//     double designWidth;
//     double designHeight;
//     double textAdjustment;

//     switch (_deviceType) {
//       case DeviceType.mobile:
//         designWidth = mobileDesignWidth;
//         designHeight = mobileDesignHeight;
//         textAdjustment = 1.0;
//         break;
//       case DeviceType.tablet:
//         designWidth = tabletDesignWidth;
//         designHeight = tabletDesignHeight;
//         textAdjustment = 0.9;
//         break;
//       case DeviceType.desktop:
//         designWidth = desktopDesignWidth;
//         designHeight = desktopDesignHeight;
//         textAdjustment = 0.97;
//         break;
//     }

//     scaleWidth = screenWidth / designWidth;
//     scaleHeight = screenHeight / designHeight;
//     scaleText = scaleWidth * textAdjustment;

//     // debugPrint('Device Type: $_deviceType');
//     // debugPrint(
//     //     'Screen: ${screenWidth.toStringAsFixed(2)} x ${screenHeight.toStringAsFixed(2)}');
//     // debugPrint(
//     //     'Scale factors - width: ${scaleWidth.toStringAsFixed(2)}, height: ${scaleHeight.toStringAsFixed(2)}, text: ${scaleText.toStringAsFixed(2)}');
//   }

//   static double width(double pixels) {
//     return pixels * scaleWidth;
//   }

//   static double height(double pixels) {
//     return pixels * scaleHeight;
//   }

//   static double text(double pixels) {
//     double baseSize;
//     switch (_deviceType) {
//       case DeviceType.mobile:
//         baseSize = pixels * 0.85;
//         break;
//       case DeviceType.tablet:
//         baseSize = pixels * 0.9;
//         break;
//       case DeviceType.desktop:
//         baseSize = pixels;
//         break;
//     }

//     return baseSize * scaleText;
//   }

//   static double getProportionateScreenWidth(double percentage) {
//     return screenWidth * (percentage / 100);
//   }

//   static double getProportionateScreenHeight(double percentage) {
//     return screenHeight * (percentage / 100);
//   }

//   static DeviceType getDeviceType() {
//     return _deviceType;
//   }

//   static DeviceType _getDeviceType() {
//     if (screenWidth < 600) {
//       return DeviceType.mobile;
//     } else if (screenWidth < 1100) {
//       return DeviceType.tablet;
//     } else {
//       return DeviceType.desktop;
//     }
//   }
// }
