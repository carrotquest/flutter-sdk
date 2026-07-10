import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static Future<bool> requestNotificationPermission() async {
    try {
      PermissionStatus status = await Permission.notification.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        status = await Permission.notification.request();
        return status.isGranted;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> checkPermissions() async {
    try {
      PermissionStatus status = await Permission.notification.status;
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }
}
