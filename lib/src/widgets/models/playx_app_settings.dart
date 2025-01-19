import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Default application settings for Playx.
///
/// The [PlayxAppSettings] class provides various configuration options for an app,
/// including debug settings, performance overlay options, and app-level shortcuts and actions.
///
/// **Note:** This class is intended to be used with Playx and provides a centralized way
/// to configure app settings that affect both debugging and runtime behavior.
class PlayxAppSettings {
  /// The title of the application.
  ///
  /// This value is passed directly to [WidgetsApp.title] and is used as the title
  /// of the application when displayed on the task switcher or app launcher.
  final String title;

  /// Whether to show the performance overlay.
  ///
  /// When set to true, displays a performance overlay to help diagnose rendering issues.
  final bool showPerformanceOverlay;

  /// Whether to show a checkerboard pattern for raster cache images.
  ///
  /// Enabling this option helps identify performance issues related to raster caching.
  final bool checkerboardRasterCacheImages;

  /// Whether to show a checkerboard pattern for offscreen layers.
  ///
  /// Enabling this option helps diagnose issues with offscreen layers.
  final bool checkerboardOffscreenLayers;

  /// Whether to show the semantics debugger.
  ///
  /// When enabled, displays a visual representation of the app's semantic structure,
  /// which can be useful for accessibility testing.
  final bool showSemanticsDebugger;

  /// Whether to show the debug banner in the app.
  ///
  /// The debug banner is a yellow banner displayed in the top-right corner of the app
  /// to indicate that the app is running in debug mode.
  final bool debugShowCheckedModeBanner;

  /// Whether to show the material grid overlay.
  ///
  /// This overlay helps visualize the layout grid used for designing Material apps.
  final bool debugShowMaterialGrid;

  /// Whether to enable logging.
  ///
  /// When enabled, logging is turned on. The default is based on the debug mode.
  final bool? enableLog;

  /// App shortcuts for handling specific key combinations.
  ///
  /// This is a map of [LogicalKeySet] to [Intent] for defining app-wide shortcuts.
  final Map<LogicalKeySet, Intent>? shortcuts;

  /// Custom scroll behavior for the application.
  ///
  /// Allows for customization of scroll behavior, such as overscroll effects and scroll physics.
  final ScrollBehavior? scrollBehavior;

  /// App-level actions mapped to specific intents.
  ///
  /// This is a map of action types to their corresponding [Action] objects for handling
  /// specific intents across the application.
  final Map<Type, Action<Intent>>? actions;

  /// The list of localizations delegates to use for the application with [PlayxLocalization].
  final List<LocalizationsDelegate>? localizationsDelegates;

  /// Creates a new [PlayxAppSettings] instance with the provided configurations.
  ///
  /// All parameters are optional, with default values provided for each.
  /// The default settings are typically suitable for most applications, but can be customized
  /// based on specific needs.
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
    this.localizationsDelegates,
  });
}
