#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint carrotquest_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'carrotquest_sdk'
  s.version          = '1.5.0'
  s.summary          = 'Carrot quest Flutter SDK: chat, push notifications and analytics for your app.'
  s.description      = <<-DESC
Flutter plugin for the Carrot quest conversational platform: in-app chat, push notifications,
user properties and event tracking. Wraps the native CarrotquestSDK for iOS.
                       DESC
  s.homepage         = 'https://github.com/carrotquest/flutter-sdk'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Carrot quest' => 'support@carrotquest.io' }
  s.source           = { :path => '.' }
  s.source_files = 'carrotquest_sdk/Sources/carrotquest_sdk/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.dependency 'CarrotquestSDK', '3.4.1'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
