import 'package:carrotquest_sdk/user_property/user_property.dart';

import 'carrotquest_sdk_platform_interface.dart';

class Carrot {
  /// Setup SDK
  static Future<void> setup(String appId, String apiKey, {String? appGroup}) {
    return CarrotquestSdkPlatform.instance.setup(appId, apiKey, appGroup);
  }

  /// Authentification user
  static Future<void> auth(String userId,
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
}
