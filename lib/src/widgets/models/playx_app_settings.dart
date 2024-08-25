import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Default app settings
class PlayxAppSettings {
  /// {@macro flutter.widgets.widgetsApp.title}
  ///
  /// This value is passed unmodified to [WidgetsApp.title].
  final String title;
  final bool showPerformanceOverlay;
  final bool checkerboardRasterCacheImages;
  final bool checkerboardOffscreenLayers;
  final bool showSemanticsDebugger;
  final bool debugShowCheckedModeBanner;
  final bool debugShowMaterialGrid;
  final bool? enableLog;

  final Map<LogicalKeySet, Intent>? shortcuts;
  final ScrollBehavior? scrollBehavior;
  final Map<Type, Action<Intent>>? actions;

  const PlayxAppSettings({
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = false,
    this.enableLog = kDebugMode,
    this.shortcuts,
    this.scrollBehavior,
    this.actions,
    this.title = '',
  });
}
