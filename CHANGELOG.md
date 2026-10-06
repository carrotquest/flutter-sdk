## 1.5.0
- Added Swift Package Manager support on iOS. The plugin now ships `ios/carrotquest_sdk/Package.swift` and gets the native SDK from the `carrotquest-ios-spm` package, so projects with Swift Package Manager enabled no longer fall back to CocoaPods for this plugin. CocoaPods is still supported.
- [iOS]: the minimum iOS version declared by the plugin is now 13.0 (the native SDK already required it).
- [iOS]: if you use a Notification Service Extension with Swift Package Manager, add the `carrotquest-ios-spm` package to the extension target with the "Up to Next Major Version" rule; Xcode resolves it to the version required by the plugin. See the push notifications section in the README.
- Updated the native SDKs: Android SDK to 3.4.2 and iOS SDK to 3.4.1.
- Both platforms now respect every mode of the "How chat conversations work" setting: multiple conversations with closed ones read-only, one conversation at a time, and the mode where users cannot start conversations and only reply to the bot. In a closed conversation the input is replaced with a "Start a new conversation" button.
- [iOS]: the native SDK is built with Swift 6 strict concurrency; the unread counter, push and custom link callbacks are now always delivered on the main thread.
- [iOS]: the realtime chat connection recovers after a silent drop, so messages no longer stop arriving until the app is restarted.
- [iOS]: fixed the unread counter coming back after an operator reply in an already open conversation; links without a scheme (e.g. `example.com`) now open correctly.
- [Android]: fixed pop-up automation chains ("pop-up → wait for event → next pop-up") not advancing after a tap inside the pop-up.
- [Android]: manual chat mailings show the full multi-paragraph text and inserted images; fixed the message text in new message notifications; more stable realtime connection.

## 1.4.0
- Added `Carrot.setTheme(CarrotTheme)` to switch the chat theme: `light`, `dark`, `fromDevice` (follow the system appearance) or `fromWeb` (use the theme configured in the admin panel). On iOS the theme is no longer forced to follow the device after `setup()`; the native SDK default is used until you call `setTheme`.
- Updated the native SDKs: Android SDK to 3.3.0 and iOS SDK to 3.3.0.
- [iOS]: the chat UI is rewritten in SwiftUI; improved light and dark appearance, the theme now follows the system appearance dynamically.
- [iOS]: the message input field is shown only when it is actually needed.
- [iOS]: fixes and improvements related to logout; 
- [Android]: tickets are now supported in the chat, the same way as in the web chat.
- [Android]: pop-ups render in under a second instead of several seconds.
- [Android]: fixed duplication of the first batch of bot messages when the bot was interrupted.
- Example app: restructured into separate screens (events, screen tracking, user properties, push, theme); added `example/example.md` with the key snippets.

## 1.3.0
- Updated the native SDKs: Android SDK to 3.2.0 and iOS SDK to 3.2.2.
- Quick-reply buttons in operator messages sent via the public API now work on both platforms.
- The app setting that allows or forbids creating multiple conversations is now respected on both platforms: if creation is forbidden, the "Write" button always opens the same conversation.
- [Android]: message replies (quoting) — reply to a specific message with a swipe or via the message actions menu.
- [Android]: significantly improved authorization reliability: fixed situations where the user unexpectedly became anonymous, or the SDK got stuck in an "offline" state on a live network until the app was reinstalled. Such states are now detected and recovered automatically.
- [Android]: the contact-collection setting is now respected in auto-replies: if it is disabled, the contact input field below an auto-reply is not shown.
- [Android]: many minor chat fixes and overall stability improvements.

## 1.2.1
- [Android]: replaced the removed `jcenter()` repository with `mavenCentral()` in the plugin's `build.gradle`. Fixes the build failure `Could not find method jcenter()` on Gradle 9+ / AGP 9+. No other changes.

## 1.2.0
- Updated the native SDKs: Android SDK to 3.1.0 and iOS SDK to 3.2.1.
- [Android]: the minimum supported SDK is raised to 21 (required by the native Android SDK 3.x). If your app targets a lower `minSdkVersion`, you must raise it to 21.
- [Android]: reworked chat with native UI components; new capabilities — attaching multiple files to a single message (previously a single file per message), voice messages, and an in-chat personal-data-processing consent block.
- [iOS]: the conversation list and header now use native UI components.
- Added the `Carrot.trackUtm(url)` method for tracking UTM tags (`utm_source`, `utm_medium`, `utm_campaign`, `utm_term`, `utm_content`) from a URL. It is intended primarily for the case when the app is opened via a deeplink (URL Scheme / Universal Link / App Link): pass the opening URL and the SDK extracts and saves the UTM tags for the current user. Can be called even before `Carrot.setup()` completes. Supported on both Android and iOS.
- Reliability: more reliable unread-conversations counter, more stable logout, and improved stability with Android code shrinking (R8/minification) enabled.
- Example app: demonstrates UTM tracking via deeplinks using the `app_links` package, including the `carrotexample` URL scheme setup for Android and iOS.

## 1.1.1
- Updated API endpoint. No other changes — behavior, public API and dependencies are unchanged. No migration needed; just bump the SDK version.

## 1.1.0
Android                                                              
Major refactoring                                                                  
- Core: completely redesigned internal logic and initialization process to improve stability and performance.
- UI: updated visual style and navigation, including the conversation list and full-screen image viewing.
- Integration: simplified SDK integration for host applications, removed deprecated components, cleaned up the codebase.  

## 1.0.2
- Improved the mechanics for recording statistics of trigger messages, ensuring more accurate and reliable activity tracking.
- [iOS] Fixed a bug where the input field could stop displaying in situations where it should be visible.
- Fixed other minor bugs to enhance the package's stability and performance.

## 1.0.1
- Slightly modified the `Carrot.sendFcmToken(token)` method to eliminate potential issues when passing the token (Android only).

## 1.0.0
- Breaking Change: Updated the initialization method signature. Passing appID is no longer required.
- Notification Permissions: Removed built-in notification permission logic to eliminate ambiguity and provide developers with more control.
- SDK Updates: Upgraded Android and iOS SDKs. These updates include numerous bug fixes and a new implementation for handling personal data consent via pop-ups.
- Documentation & Examples: Refreshed the example project and polished the documentation for better clarity.

## 0.0.24
- Fixed the bug with userAgent for Android
- Added validation for the correctness of the apiKey for Android

## 0.0.23
- Upgraded AndroidSDK
- Upgrade iOS SDK

## 0.0.22
- Upgraded AndroidSDK
- Fixed initialization result for iOS

## 0.0.21
- Upgraded AndroidSDK
- Supported AGP 8.x
- Fixed bugs

## 0.0.20
- Reduced the supported Java version
- Fixed bugs

## 0.0.19
- Upgrade Android SDK
- Upgrade iOS SDK

## 0.0.18
- Upgrade Android SDK
- Upgrade iOS SDK

## 0.0.17
- Upgrade AndroidSDK

## 0.0.16
- Fixed bugs

## 0.0.15
- Added a phone mask for bot responses
- Fixed bugs

## 0.0.14
- Added support for in-app navigation tracking
- Fixed bugs

## 0.0.13
- Fixed chat lags on Android

## 0.0.12
- Now the auth returns the value of the carrot_id field (iOS)

## 0.0.11
- Fixed the bug with file uploading
- Fixed the bug with class visibility after obfuscation
- Now the auth returns the value of the carrot_id field (Android)

## 0.0.10
- iPadOS minimum support added
- Fix UI when rotate screen (iOS)
- Fix send file logic (iOS)

## 0.0.9
- Added support for `isInit` method on Android
- Improved behavior when there is no internet connection
- Worked on notifications and fixed bugs
- Fixed other minor bugs

## 0.0.8
- More bugs fix

## 0.0.7 
- Fix bugs

## 0.0.6 
- Added support for customizable placeholders for bot questions
- Fix bugs.

## 0.0.5 
- Fix bugs.

## 0.0.4 
- Added the ability to authorize using a hash.

## 0.0.3 
- Fixed problems with receiving messages from bots
- Fixed other problems related to bots
- Fix some auth bug
- Changed mechanism of requesting access to photos. Now it happens automatically and on demand (only for iOS)

## 0.0.2 
- Update documentation

## 0.0.1 
- First release

