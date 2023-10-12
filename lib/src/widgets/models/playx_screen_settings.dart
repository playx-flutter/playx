import 'dart:ui';

import 'package:playx_widget/playx_widget.dart';

/// Screen Util parameters:
class PlayxScreenSettings {
  final Size designSize;
  final bool splitScreenMode;
  final bool minTextAdapt;
  final bool useInheritedMediaQuery;
  final RebuildFactor rebuildFactor;
  final bool? ensureScreenSize;
  final FontSizeResolver fontSizeResolver;
  final Iterable<String>? responsiveWidgets;

  const PlayxScreenSettings({
    this.splitScreenMode = true,
    this.minTextAdapt = true,
    this.useInheritedMediaQuery = false,
    this.rebuildFactor = RebuildFactors.size,
    this.designSize = const Size(360, 690),
    this.ensureScreenSize,
    this.fontSizeResolver = FontSizeResolvers.width,
    this.responsiveWidgets,
  });
}
