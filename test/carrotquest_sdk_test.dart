import 'package:carrotquest_sdk/user_property/user_property.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carrotquest_sdk/carrotquest_sdk_method_channel.dart';
import 'package:carrotquest_sdk/carrotquest_sdk_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCarrotquestSdkPlatform
    with MockPlatformInterfaceMixin
    implements CarrotquestSdkPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> openChat() {
    return Future.value();
  }

  @override
  Future<void> setup(String appId, String apiKey, String? appGroup) {
    return Future.value();
  }

  @override
  Future<String?> auth(userId, {String? userAuthKey, String? userHash}) {
    return Future.value("");
  }

  @override
  Future<void> sendFcmToken(String token) {
    return Future.value();
  }

  @override
  Future<void> sendFirebasePushNotification(Map<String, dynamic> message) {
    return Future.value();
  }

  @override
  Future<void> setUserProperty(UserProperty property) {
    return Future.value();
  }

  @override
  Future<void> trackEvent(String event, {Map<String, String>? params}) {
    return Future.value();
  }

  @override
  Future<int> getUnreadConversationsCount() {
    return Future.value(0);
  }

  @override
  Future<void> logOut() {
    return Future.value();
  }

  @override
  Stream<int> getUnreadConversationsCountStream() {
    return Stream.value(0);
  }

  @override
  Future<void> pushCampaignsUnsubscribe() {
    return Future.value();
  }

  @override
  Future<void> pushNotificationsUnsubscribe() {
    return Future.value();
  }

  @override
  Future<bool> isInit() {
    return Future.value(true);
  }

  @override
  Future<void> trackScreen(String screen) {
    return Future.value();
  }
}

void main() {
  final CarrotquestSdkPlatform initialPlatform =
      CarrotquestSdkPlatform.instance;

  test('$MethodChannelCarrotquestSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCarrotquestSdk>());
  });

  test('getPlatformVersion', () async {
    MockCarrotquestSdkPlatform fakePlatform = MockCarrotquestSdkPlatform();
    CarrotquestSdkPlatform.instance = fakePlatform;

    //expect(await Carrot.getPlatformVersion(), '42');
  });
}
