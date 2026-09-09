import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carrotquest_sdk/carrot_theme.dart';
import 'package:carrotquest_sdk/carrotquest_sdk_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelCarrotquestSdk platform = MethodChannelCarrotquestSdk();
  const MethodChannel channel = MethodChannel('carrotquest_sdk');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test('trackUtm', () async {
    MethodCall? captured;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        captured = methodCall;
        return null;
      },
    );

    const url = 'https://example.com/?utm_source=google&utm_medium=cpc';
    await platform.trackUtm(url);

    expect(captured?.method, 'trackUtm');
    expect(captured?.arguments, {'url': url});
  });

  test('setTheme', () async {
    MethodCall? captured;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        captured = methodCall;
        return null;
      },
    );

    await platform.setTheme(CarrotTheme.fromDevice);

    expect(captured?.method, 'setTheme');
    expect(captured?.arguments, {'theme': 'from_device'});
  });
}
