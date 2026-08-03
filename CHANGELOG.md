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

