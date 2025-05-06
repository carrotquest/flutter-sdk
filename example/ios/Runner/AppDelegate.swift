import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      if #available(iOS 10.0, *) {
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
      } else {
        let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
      }

      application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

import CarrotSDK

extension AppDelegate {
    
    private func getAppGroup() -> String {
        return "group.cq.flutterSdkExample"
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let notificationService = CarrotNotificationService.shared
        if notificationService.canHandle(notification) {
            notificationService.show(notification, appGroudDomain: self.getAppGroup(), completionHandler: completionHandler)
        } else {
            // Логика для пользовательских уведомлений
        }
    }

    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notificationService = CarrotNotificationService.shared
        if notificationService.canHandle(response) {
            notificationService.clickNotification(notificationResponse: response, appGroudDomain: self.getAppGroup())
        } else {
            // Логика для пользовательских уведомлений
        }
    }
}
