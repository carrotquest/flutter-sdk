import 'package:flutter/material.dart';
//import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static Future<bool> requestNotificationPermission(
      BuildContext context) async {
    // PermissionStatus status = await Permission.notification.status;

    // if (status.isGranted) {
    //   return Future.value(true);
    // }

    // if (status.isDenied) {
    //   status = await Permission.notification.request();

    //   if (status.isGranted) {
    //     return Future.value(true);
    //   } else {
    //     debugPrint(":(");
    //     return Future.value(false);
    //   }
    // }
    //return Future.value(false);

    return Future.value(true);
  }

  static Future<bool> checkPermissions() async {
    // PermissionStatus status = await Permission.notification.status;

    // return status.isGranted;

    return true;
  }
}
