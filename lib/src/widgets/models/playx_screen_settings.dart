import 'dart:ui';

import 'package:playx_widget/playx_widget.dart';

/// Screen Util parameters for configuring screen-related settings in a Flutter application.
///
/// The [PlayxScreenSettings] class provides various options for adapting your app's UI
/// to different screen sizes and orientations. This class helps manage screen-related
/// parameters such as design size, text adaptation, and responsive widgets.
class PlayxScreenSettings {
  /// The design size used for layout calculations. This represents the base size
  /// for which the UI is designed. It is used to scale the app's UI according to
  /// the actual screen size.
  final Size designSize;

  /// Whether to enable split-screen mode. If true, the app will adjust its layout
  /// to support split-screen functionality, typically on devices that allow for
  /// multiple apps to be visible at once.
  final bool splitScreenMode;

  /// Whether to enable minimal text adaptation. If true, text size adjustments
  /// will be minimal and based on the design size, making text adapt more subtly
  /// to different screen sizes.
  final bool minTextAdapt;

  /// Whether to use [InheritedMediaQuery] to provide media query information
  /// to descendant widgets. If true, this allows widgets to access media query
  /// data from parent widgets, which can help with responsive design.
  final bool useInheritedMediaQuery;

  /// The factor used to determine when to rebuild the UI. This could be based on
  /// size, orientation, or other factors, depending on the [RebuildFactor] used.
  final RebuildFactor rebuildFactor;

  /// Whether to ensure that the screen size is respected. If true, the app will
  /// ensure that the design size constraints are applied, helping to maintain
  /// consistency in UI layout.
  final bool ensureScreenSize;

  /// The font size resolver used to determine text sizes. This can be based on
  /// screen width, height, or other criteria. It helps in adjusting font sizes
  /// according to the screen dimensions.
  final FontSizeResolver fontSizeResolver;

  /// An iterable of widget keys or names that should be responsive. If specified,
  /// these widgets will adapt their layout based on the screen size and other
  /// responsive settings.
  final Iterable<String>? responsiveWidgets;

  const PlayxScreenSettings({
    this.splitScreenMode = true,
    this.minTextAdapt = true,
    this.useInheritedMediaQuery = false,
    this.rebuildFactor = RebuildFactors.size,
    this.designSize = const Size(360, 690),
    this.ensureScreenSize = false,
    this.fontSizeResolver = FontSizeResolvers.width,
    this.responsiveWidgets,
  });
}
