import 'package:flutter/foundation.dart';
import 'package:playx_widget/playx_widget.dart';

/// Platform-specific settings for configuring the appearance and behavior of widgets.
///
/// The [PlayxPlatformSettings] class allows you to customize various platform-specific
/// settings for both Material and Cupertino styles in a Flutter application.
///
/// **Note:** Adjusting these settings can impact the appearance and functionality
/// of platform-specific widgets and their behavior in your app.
class PlayxPlatformSettings {
  /// The initial platform to use for the application. This can be set to control
  /// which platform-specific widgets and styles are applied initially.
  final TargetPlatform? initialPlatform;

  /// Whether to add a [Material] widget to [CupertinoScaffold], [CupertinoTabScaffold],
  /// and [CupertinoAlertDialog]. This is required when using a PlatformApp, as some
  /// Material widgets expect a Material parent. Note that this may affect fonts and colors
  /// and may not work seamlessly with dark mode in all cases.
  ///
  /// Note: This may also cause a ripple effect on widgets that previously did not exhibit this behavior.
  final bool iosUsesMaterialWidgets;

  /// Whether to set the padding of [PlatformIconButton] to [EdgeInsets.zero] when
  /// placed inside a [PlatformAppBar]. This only affects padding for the Cupertino style
  /// and only if no padding is already defined. It will affect all [PlatformIconButton]s
  /// added to the [PlatformAppBar].
  final bool iosUseZeroPaddingForAppbarPlatformIcon;

  /// The style each platform will use. This can be either [PlatformStyle.Material] or
  /// [PlatformStyle.Cupertino], controlling the overall appearance and behavior of widgets.
  final PlatformStyleData platformStyle;

  /// Whether to wrap the middle title of a [PlatformAppBar] with a [MediaQuery] for Cupertino
  /// [CupertinoNavigationBar]. This resolves specific layout issues with titles as described in
  /// https://github.com/flutter/flutter/issues/42759. Defaults to true, which may be a breaking change.
  /// Set this value to false if you encounter issues.
  final bool wrapCupertinoAppBarMiddleWithMediaQuery;

  const PlayxPlatformSettings({
    this.initialPlatform,
    this.iosUsesMaterialWidgets = true,
    this.iosUseZeroPaddingForAppbarPlatformIcon = false,
    this.platformStyle = const PlatformStyleData(),
    this.wrapCupertinoAppBarMiddleWithMediaQuery = true,
  });
}
