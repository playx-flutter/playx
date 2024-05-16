import 'package:flutter/foundation.dart';
import 'package:playx_widget/playx_widget.dart';

class PlayxPlatformSettings {
  final TargetPlatform? initialPlatform;

  /// Adds a [Material] widget to [CupertinoScaffold], [CupertinoTabScaffold] and
  /// [CupertinoAlertDialog] to allow for Material widgets to be used. This is required
  /// when using a PlatformApp since some Material widgets will expect a Material parent,
  /// otherwise an exception is thrown.
  /// Note: This may affect fonts and colors and dark mode may not work in all cases.
  /// Note: This may cause widgets to show a ripple effect where as before 1.6.0 it did not
  final bool iosUsesMaterialWidgets;

  /// Sets any padding of the [PlatformIconButton] to [EdgeInserts.zero] when placed inside
  /// a [PlatformAppBar]. Only affects the padding for the cupertino style and only if no padding
  /// is already defined. Will affect all [PlatformIconButton]s added to the [PlatformAppBar]
  final bool iosUseZeroPaddingForAppbarPlatformIcon;

  /// The style each platform will use. Either [PlatformStyle.Material] or
  /// [PlatformStyle.Cupertino].
  final PlatformStyleData platformStyle;

  /// Add MediaQuery as a parent to any given title value for a [PlatformAppBar] for the cupertino [CupertinoNavigationBar]
  /// This is to resolve the somewhat strange behaviour as described in https://github.com/flutter/flutter/issues/42759
  /// Set to true (wrapped) by default which could be a breaking change. If it is then set this value to false
  final bool wrapCupertinoAppBarMiddleWithMediaQuery;

  const PlayxPlatformSettings({
    this.initialPlatform,
    this.iosUsesMaterialWidgets = true,
    this.iosUseZeroPaddingForAppbarPlatformIcon = false,
    this.platformStyle = const PlatformStyleData(),
    this.wrapCupertinoAppBarMiddleWithMediaQuery = true,
  });
}
