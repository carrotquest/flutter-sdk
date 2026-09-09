/// Color theme of the SDK chat UI.
enum CarrotTheme {
  /// Light theme.
  light,

  /// Dark theme.
  dark,

  /// Follow the device (system) appearance.
  fromDevice,

  /// Use the theme configured in the Carrot quest admin panel.
  fromWeb;

  String get channelValue {
    switch (this) {
      case CarrotTheme.light:
        return 'light';
      case CarrotTheme.dark:
        return 'dark';
      case CarrotTheme.fromDevice:
        return 'from_device';
      case CarrotTheme.fromWeb:
        return 'from_web';
    }
  }
}
