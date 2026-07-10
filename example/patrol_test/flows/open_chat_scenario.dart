import 'dart:io';

import 'package:carrotquest_sdk_example/keys/keys.dart';
import 'package:patrol/patrol.dart';

import 'base_test_scenario.dart';

final class OpenChatFlow extends BaseTestScenario {
  const OpenChatFlow(super.$, {required super.next});

  @override
  Future<bool> run() async {
    await $.pumpAndSettle();

    await $(K.mainScreenKey.openChatButtonKey).tap();
    if (await $.platform.mobile.isPermissionDialogVisible()) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }

    await $.platform.mobile.tap(MobileSelector(
      android: AndroidSelector(
        className: 'android.widget.Button',
        instance: 0,
      ),
      ios: IOSSelector(
        label: 'menu',
      ),
    ));
    if (Platform.isAndroid) {
      await $.platform.mobile.waitUntilVisible(Selector(
        text: 'Write',
      ));
    }
    await $.platform.mobile.waitUntilVisible(MobileSelector(
      android: AndroidSelector(
        text: "We haven't talked yet",
      ),
      ios: IOSSelector(
        text: "You don't have any conversations",
      ),
    ));
    await $.platform.mobile.tap(MobileSelector(
      android: AndroidSelector(
        className: 'android.widget.Button',
        instance: 0,
      ),
      ios: IOSSelector(
        elementType: IOSElementType.button,
        instance: 0,
      ),
    ));
    if (Platform.isIOS) {
      await $.platform.mobile.tap(IOSSelector(
        label: 'times small',
      ));
    }
    await $(K.mainScreenKey.openChatButtonKey).waitUntilVisible();

    return true;
  }

  @override
  Future<bool> waitAndCheckValid() async {
    await $(K.mainScreenKey.openChatButtonKey).waitUntilVisible();
    return $(K.mainScreenKey.openChatButtonKey).exists;
  }
}
