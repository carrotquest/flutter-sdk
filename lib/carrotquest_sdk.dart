import 'package:carrotquest_sdk/carrot_theme.dart';
import 'package:carrotquest_sdk/user_property/user_property.dart';

import 'carrotquest_sdk_platform_interface.dart';

export 'carrot_theme.dart';

class Carrot {
  /// Setup SDK
  static Future<bool> setup(String apiKey, {String? appGroup}) {
    return CarrotquestSdkPlatform.instance.setup(apiKey, appGroup);
  }

  /// Authentification user
  static Future<String?> auth(String userId,
      {String? userAuthKey, String? userHash}) {
    return CarrotquestSdkPlatform.instance.auth(
      userId,
      userAuthKey: userAuthKey,
      userHash: userHash,
    );
  }

  /// Deinitialisation SDK
  static Future<void> logOut() {
    return CarrotquestSdkPlatform.instance.logOut();
  }

  /// Set user property
  Future<void> setUserProperty(UserProperty property) {
    return CarrotquestSdkPlatform.instance.setUserProperty(property);
  }

  /// Track event
  static Future<void> trackEvent(String event, {Map<String, String>? params}) {
    return CarrotquestSdkPlatform.instance.trackEvent(event, params: params);
  }

  /// Open chat
  static Future<void> openChat() {
    return CarrotquestSdkPlatform.instance.openChat();
  }

  /// Set the color theme of the chat UI
  ///
  /// Call it after [setup] (and after [auth], if you use it) has completed.
  static Future<void> setTheme(CarrotTheme theme) {
    return CarrotquestSdkPlatform.instance.setTheme(theme);
  }

  /// Get count unread conversations
  static Future<int> getUnreadConversationsCount() {
    return CarrotquestSdkPlatform.instance.getUnreadConversationsCount();
  }

  /// Get count unread conversations stream
  static Stream<int> getUnreadConversationsCountStream() {
    return CarrotquestSdkPlatform.instance.getUnreadConversationsCountStream();
  }

  /// Send FCM Token to Carrot quest
  static Future<void> sendFcmToken(String token) {
    return CarrotquestSdkPlatform.instance.sendFcmToken(token);
  }

  /// Send FCM push to Carrot quest SDK
  static Future<void> sendFirebasePushNotification(
      Map<String, dynamic> message) {
    return CarrotquestSdkPlatform.instance
        .sendFirebasePushNotification(message);
  }

  /// Check Carrot quest push
  static bool isCarrotQuestPush(Map<String, dynamic> message) {
    return message['is_carrot'] != null;
  }

  /// Unsubscribe from all push notifications
  static Future<void> pushNotificationsUnsubscribe() {
    return CarrotquestSdkPlatform.instance.pushNotificationsUnsubscribe();
  }

  /// Unsubscribe from campaigns push notifications
  static Future<void> pushCampaignsUnsubscribe() {
    return CarrotquestSdkPlatform.instance.pushCampaignsUnsubscribe();
  }

  /// Check whether the sdk is initialized
  ///
  /// Currently implemented for Android only.
  static Future<bool> isInit() {
    return CarrotquestSdkPlatform.instance.isInit();
  }

  static Future<void> trackScreen(String screen) {
    return CarrotquestSdkPlatform.instance.trackScreen(screen);
  }

  /// Track UTM tags from a URL
  ///
  /// Pass a URL string containing UTM parameters (e.g. `utm_source`,
  /// `utm_medium`, `utm_campaign`, `utm_term`, `utm_content`). The SDK parses
  /// the tags from the URL and saves them for the current user.
  static Future<void> trackUtm(String url) {
    return CarrotquestSdkPlatform.instance.trackUtm(url);
  }
}
