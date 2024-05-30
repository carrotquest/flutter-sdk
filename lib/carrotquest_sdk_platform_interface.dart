import 'package:carrotquest_sdk/user_property/user_property.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'carrotquest_sdk_method_channel.dart';

abstract class CarrotquestSdkPlatform extends PlatformInterface {
  /// Constructs a CarrotquestSdkPlatform.
  CarrotquestSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static CarrotquestSdkPlatform _instance = MethodChannelCarrotquestSdk();

  /// The default instance of [CarrotquestSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelCarrotquestSdk].
  static CarrotquestSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CarrotquestSdkPlatform] when
  /// they register themselves.
  static set instance(CarrotquestSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> setup(String appId, String apiKey, String? appGroup) {
    throw UnimplementedError('setup() has not been implemented.');
  }

  Future<void> auth(String userId, {String? userAuthKey, String? userHash}) {
    throw UnimplementedError('auth() has not been implemented.');
  }

  Future<void> logOut() {
    throw UnimplementedError('logOut() has not been implemented.');
  }

  Future<void> sendFcmToken(String token) {
    throw UnimplementedError('openChat() has not been implemented.');
  }

  Future<void> sendFirebasePushNotification(Map<String, dynamic> message) {
    throw UnimplementedError(
        'sendFirebasePushNotification() has not been implemented.');
  }

  Future<void> openChat() {
    throw UnimplementedError('openChat() has not been implemented.');
  }

  Future<void> setUserProperty(UserProperty property) {
    throw UnimplementedError('setUserProperty() has not been implemented.');
  }

  Future<void> trackEvent(String event, {Map<String, String>? params}) {
    throw UnimplementedError('trackEvent() has not been implemented.');
  }

  Future<int> getUnreadConversationsCount() {
    throw UnimplementedError(
        'getunreadConversationsCount() has not been implemented.');
  }

  Stream<int> getUnreadConversationsCountStream() {
    throw UnimplementedError(
        'getUnreadConversationsCountStream() has not been implemented.');
  }

  Future<void> pushNotificationsUnsubscribe() {
    throw UnimplementedError(
        'pushNotificationsUnsubscribe() has not been implemented.');
  }

  Future<void> pushCampaignsUnsubscribe() {
    throw UnimplementedError(
        'pushCampaignsUnsubscribe() has not been implemented.');
  }

  Future<bool> isInit() {
    throw UnimplementedError('isInit() has not been implemented.');
  }
}
