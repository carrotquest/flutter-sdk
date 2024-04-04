import Flutter
import UIKit
import CarrotSDK
import Photos

public class CarrotquestSdkPlugin: NSObject, FlutterPlugin {
  private var channel: FlutterMethodChannel? = nil

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "carrotquest_sdk", binaryMessenger: registrar.messenger())
    let instance = CarrotquestSdkPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch call.method {
      case "getPlatformVersion":
          result("iOS " + UIDevice.current.systemVersion)
      case "setup":
          self._setup(with: call, and: result)
      case "auth":
          self._auth(with: call, and: result)
      case "logOut":
          self._logOut(with: call, and: result)
      case "sendToken":
          self._sendPushToken(with: call, and: result)
      case "sendFirebasePushNotification":
          self._sendFirebasePushNotification(with: call, and: result)
      case "setUserProperty":
          self._setUserProperty(with: call, and: result)
      case "trackEvent":
          self._trackEvent(with: call, and: result)
      case "getUnreadConversationsCount":
          self._getUnreadConversationsCount(with: result)
      case "openChat":
          self._openChat(with: result)
      case "pushNotificationsUnsubscribe":
          self._pushNotificationsUnsubscribe()
      case "pushCampaignsUnsubscribe":
          self._pushCampaignsUnsubscribe()
      default:
          result(FlutterMethodNotImplemented)
      }
  }

  private func _setup(with call: FlutterMethodCall, and result: @escaping FlutterResult) {
    guard let args = call.arguments as? NSDictionary else { return }
    guard let apiKey = args["api_key"] as? String else { return }
    let appGroup = args["app_group"] as? String
    Carrot.shared.setup(
        withApiKey: apiKey,
        withTheme: .fromMobile,
        withAppGroup: appGroup,
        successHandler: {
            Carrot.shared.getUnreadConversationsCount { [weak self] count in
                guard let self = self else { return }
                self.channel?.invokeMethod("unreadConversationsCount", arguments: count)
            }
//             result(nil)
        },
        errorHandler: { e in
//             result(FlutterError(code: "setup", message: "setup error", details: e))
        }
    )
    result(nil)
  }

    private func _openChat(with result: @escaping FlutterResult) {
      Carrot.shared.openChat()
      result(nil)
    }

private func _auth(with call: FlutterMethodCall, and result: @escaping FlutterResult) {
      guard let args = call.arguments as? NSDictionary else { return }
      //guard let userAuthKey = args["user_auth_key"] as? String else { return }
      let userAuthKey = args["user_auth_key"] as? String
      let userHash = args["user_hash"] as? String
        if userAuthKey == nil && userHash == nil { return }
        guard let userId = args["user_id"] as? String else {return}


        if userAuthKey == nil {
            if let unwrappedUserHash = userHash {
                Carrot.shared.hashedAuth(withUserId: userId, withHash: unwrappedUserHash, successHandler: {
                    result(nil)
                }, errorHandler: { e in result(FlutterError(code: "auth", message: "auth error", details: e))})
                return
            } else {
                return
            }
        }
        if let unwrappeduserAuthKey = userAuthKey {
            Carrot.shared.auth(withUserId: userId, withUserAuthKey: unwrappeduserAuthKey, successHandler: {
                result(nil)
            }, errorHandler: { e in result(FlutterError(code: "auth", message: "auth error", details: e))})
        }
    }

    private func _setUserProperty(with call: FlutterMethodCall, and result: @escaping FlutterResult) {
      guard let args = call.arguments as? NSDictionary else { return }
      guard let keyProperty = args["key"] as? String else { return }
      guard let valueProperty = args["value"] as? String else {return}
      let userProperties:[UserProperty] = [UserProperty(key: keyProperty, value: valueProperty)]

        Carrot.shared.setUserProperty(userProperties)
        result(nil)
    }

    private func _trackEvent(with call: FlutterMethodCall, and result: @escaping FlutterResult) {
      guard let args = call.arguments as? NSDictionary else { return }
      guard let event = args["event"] as? String else { return }
      guard let params = args["params"] as? String else {
          Carrot.shared.trackEvent(withName: event, withParams: "")
          result(nil)
          return
      }

        Carrot.shared.trackEvent(withName: event, withParams: params)
        result(nil)
    }

    private func _getUnreadConversationsCount(with result: @escaping FlutterResult) {
        Carrot.shared.getUnreadConversationsCount({count in result(count)})
    }

    private func _logOut(with call: FlutterMethodCall, and result: @escaping FlutterResult) {
        Carrot.shared.logout(successHandler: {
            result(nil)
        }, errorHandler: { e in result(FlutterError(code: "logOut", message: "logOut error", details: e))})
    }

    private func _sendPushToken(with call: FlutterMethodCall, and result: @escaping FlutterResult) {
        guard let args = call.arguments as? NSDictionary else { return }
        guard let token = args["token"] as? String else { return }
        CarrotNotificationService.shared.setToken(token)
        result(nil)
    }

    private func _sendFirebasePushNotification(with call: FlutterMethodCall, and result: @escaping FlutterResult) {
        guard let args = call.arguments as? NSDictionary else { return }
        guard let userInfo = args["data"] as? [String: Any] else { return }
//          CarrotNotificationService.shared.show(from: userInfo)
        result(nil)
    }

    private func _pushNotificationsUnsubscribe() {
        CarrotNotificationService.shared.pushNotificationsUnsubscribe()
    }

    private func _pushCampaignsUnsubscribe() {
        CarrotNotificationService.shared.pushCampaignsUnsubscribe()
    }
}

