import 'package:dimpos_store/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> setThemeMode(String? value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString(Constants.themeModeKey, value!);
}

Future<String?> getThemeMode() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(Constants.themeModeKey);
}

Future<bool> setAccessToken(String? value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString(Constants.accessTokenKey, value!);
}

Future<String?> getAccessToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(Constants.accessTokenKey);
}

Future<bool> removeAccessToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.remove(Constants.accessTokenKey);
}

Future<bool> setRefreshToken(String? value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString(Constants.refreshTokenKey, value!);
}

Future<String?> getRefreshToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(Constants.refreshTokenKey);
}

Future<bool> removeRefreshToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.remove(Constants.refreshTokenKey);
}

Future<String?> getBillPrinter() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(Constants.billPrinterKey);
}

Future<bool> setBillPrinter(String? value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString(Constants.billPrinterKey, value!);
}

Future<bool> removeBillPrinter() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.remove(Constants.billPrinterKey);
}
