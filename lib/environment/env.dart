import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'API_BASE_URL', obfuscate: true)
  static final String apiBaseUrl = _Env.apiBaseUrl;
  @EnviedField(varName: 'API_IDENTITY_URL', obfuscate: true)
  static final String apiIdentityUrl = _Env.apiIdentityUrl;
  @EnviedField(varName: 'API_MENU_URL', obfuscate: true)
  static final String apiMenuUrl = _Env.apiMenuUrl;
  @EnviedField(varName: 'API_STORE_URL', obfuscate: true)
  static final String apiStoreUrl = _Env.apiStoreUrl;
  @EnviedField(varName: 'API_PROMOTION_URL', obfuscate: true)
  static final String apiPromotionUrl = _Env.apiPromotionUrl;
  @EnviedField(varName: 'API_BASKET_URL', obfuscate: true)
  static final String apiBasketUrl = _Env.apiBasketUrl;
  @EnviedField(varName: 'API_ORDER_URL', obfuscate: true)
  static final String apiOrderUrl = _Env.apiOrderUrl;
  @EnviedField(varName: 'API_NOTIFICATION_URL', obfuscate: true)
  static final String apiNotificationUrl = _Env.apiNotificationUrl;
  @EnviedField(varName: 'API_INVENTORY_URL', obfuscate: true)
  static final String apiInventoryUrl = _Env.apiInventoryUrl;

  @EnviedField(varName: 'NOTIFICATION_HUB_URL', obfuscate: true)
  static final String notificationHubUrl = _Env.notificationHubUrl;
}
