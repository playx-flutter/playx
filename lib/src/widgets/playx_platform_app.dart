import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playx/src/widgets/get_platform_app.dart';
import 'package:playx_localization/playx_localization.dart';
import 'package:playx_theme/playx_theme.dart';
import 'package:playx_widget/playx_widget.dart';
import 'package:sentry_flutter/sentry_flutter.dart';


///PlayxPlatformApp : A widget that wraps [GetMaterialApp] or [ GetCupertinoApp] based on the platform
///with [PlayXThemeBuilder] to update the app with current theme
///and [ScreenUtilInit] that initializes [ScreenUtil]
/// With the ability to set app orientation and more.
class PlayxPlatformApp extends StatelessWidget {
  //orientation
  /// Sets your preferred orientations of the Material app.
  final List<DeviceOrientation> preferredOrientations;

  final PlayxPlatformSettings platformSettings;
  final PlayxScreenSettings screenSettings;
  final PlayxThemeSettings themeSettings;
  final PlayxNavigationSettings navigationSettings;
  final PlayxAppSettings appSettings;

  //Get material app parameters
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final Widget? home;
  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final Color? color;
  final TextDirection? textDirection;
  final Map<LogicalKeySet, Intent>? shortcuts;
  final ScrollBehavior? scrollBehavior;
  final Map<Type, Action<Intent>>? actions;
  final VoidCallback? onInit;
  final VoidCallback? onReady;
  final VoidCallback? onDispose;
  final LogWriterCallback? logWriterCallback;
  final bool? popGesture;

  ///Whether should include sentry navigator observer or not..
  final bool includeSentryNavigationObserver;

  const PlayxPlatformApp({
    super.key,
    this.preferredOrientations = const [
      DeviceOrientation.portraitUp,
    ],
    this.platformSettings = const PlayxPlatformSettings(),
    this.screenSettings = const PlayxScreenSettings(),
     this.themeSettings = const PlayxThemeSettings(),
     this.navigationSettings = const PlayxNavigationSettings(),
     this.appSettings = const PlayxAppSettings(),
    this.scaffoldMessengerKey,
    this.home,
    this.textDirection,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.shortcuts,
    this.scrollBehavior,
    this.onInit,
    this.onReady,
    this.onDispose,
    this.logWriterCallback,
    this.popGesture,
    this.actions,
    this.includeSentryNavigationObserver = true,
  });

  @override
  Widget build(BuildContext context) {
    return PlayXThemeBuilder(builder: (xTheme) {
      themeSettings.onThemeChanged?.call(xTheme);
      SystemChrome.setPreferredOrientations(preferredOrientations);
      return ScreenUtilInit(
          designSize: screenSettings.designSize,
          minTextAdapt: screenSettings.minTextAdapt,
          splitScreenMode: screenSettings.splitScreenMode,
          useInheritedMediaQuery: screenSettings.useInheritedMediaQuery,
          rebuildFactor: screenSettings.rebuildFactor,
          fontSizeResolver: screenSettings.fontSizeResolver,
          responsiveWidgets: screenSettings.responsiveWidgets,
          ensureScreenSize: screenSettings.ensureScreenSize,
          builder: (context, child) {
            return PlayxLocalizationBuilder(builder: (locale) {
              return PlatformProvider(
                initialPlatform: platformSettings.initialPlatform,
                settings: PlatformSettingsData(
                  iosUsesMaterialWidgets:platformSettings.iosUsesMaterialWidgets,
                  iosUseZeroPaddingForAppbarPlatformIcon :platformSettings.iosUseZeroPaddingForAppbarPlatformIcon,
                  legacyIosUsesMaterialWidgets : false,
                  platformStyle :platformSettings.platformStyle,
                  wrapCupertinoAppBarMiddleWithMediaQuery :platformSettings.wrapCupertinoAppBarMiddleWithMediaQuery,
                ),
                builder: (context) => GetPlatformApp(
                  theme: themeSettings.theme ?? xTheme.theme(locale.locale),
                  cupertinoTheme: themeSettings.cupertinoTheme ?? xTheme.cupertinoTheme?.call(locale.locale),
                  debugShowCheckedModeBanner: appSettings.debugShowCheckedModeBanner,
                  navigatorObservers: navigationSettings.navigatorObservers ??
                      [
                        if (includeSentryNavigationObserver)
                          SentryNavigatorObserver(),
                      ],
                  navigatorKey: navigationSettings.navigatorKey,
                  scaffoldMessengerKey: scaffoldMessengerKey,
                  home: home,
                  routes: navigationSettings.routes,
                  initialRoute: navigationSettings.initialRoute,
                  onGenerateRoute: navigationSettings.onGenerateRoute,
                  onGenerateInitialRoutes: navigationSettings.onGenerateInitialRoutes,
                  onUnknownRoute:navigationSettings.onUnknownRoute,
                  builder: navigationSettings.builder,
                  textDirection: textDirection,
                  title: title,
                  onGenerateTitle: onGenerateTitle,
                  color: color,
                  darkTheme: themeSettings.darkTheme,
                  themeMode: themeSettings.themeMode,
                  supportedLocales: PlayxLocalization.supportedLocales,
                  localizationsDelegates:
                      PlayxLocalization.localizationDelegates,
                  locale: PlayxLocalization.currentLocale,
                  debugShowMaterialGrid: appSettings.debugShowMaterialGrid,
                  showPerformanceOverlay: appSettings.showPerformanceOverlay,
                  checkerboardRasterCacheImages: appSettings.checkerboardRasterCacheImages,
                  checkerboardOffscreenLayers: appSettings.checkerboardOffscreenLayers,
                  showSemanticsDebugger: appSettings.showSemanticsDebugger,
                  shortcuts: shortcuts,
                  scrollBehavior: scrollBehavior,
                  customTransition: navigationSettings.customTransition,
                  onInit: onInit,
                  onReady: onReady,
                  onDispose: onDispose,
                  routingCallback: navigationSettings.routingCallback,
                  defaultTransition: navigationSettings.defaultTransition,
                  getPages: navigationSettings.getPages,
                  opaqueRoute: navigationSettings.opaqueRoute,
                  enableLog: appSettings.enableLog,
                  logWriterCallback: logWriterCallback,
                  popGesture: popGesture,
                  transitionDuration: navigationSettings.transitionDuration,
                  defaultGlobalState: navigationSettings.defaultGlobalState,
                  smartManagement: navigationSettings.smartManagement,
                  initialBinding: navigationSettings.initialBinding,
                  unknownRoute: navigationSettings.unknownRoute,
                  highContrastTheme: themeSettings.highContrastTheme,
                  highContrastDarkTheme: themeSettings.highContrastDarkTheme,
                  actions: actions,
                ),
              );
            });
          });
    });
  }
}



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


///Default theme settings
class PlayxThemeSettings {
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;
  final CupertinoThemeData? cupertinoTheme;
  final ThemeData? highContrastTheme;
  final ThemeData? highContrastDarkTheme;

  ///Callback that is called when the theme is updated.
  final Function(XTheme)? onThemeChanged;

  const PlayxThemeSettings({
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
    this.cupertinoTheme,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.onThemeChanged,
  });
}


///Default navigation settings
class PlayxNavigationSettings {
  final GlobalKey<NavigatorState>? navigatorKey;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final InitialRouteListFactory? onGenerateInitialRoutes;
  final RouteFactory? onUnknownRoute;
  final List<NavigatorObserver>? navigatorObservers;
  final TransitionBuilder? builder;
  final CustomTransition? customTransition;
  final Duration? transitionDuration;
  final bool? defaultGlobalState;
  final List<GetPage>? getPages;
  final GetPage? unknownRoute;
  final ValueChanged<Routing?>? routingCallback;
  final Transition? defaultTransition;
  final bool? opaqueRoute;
  final SmartManagement smartManagement;
  final Bindings? initialBinding;

  const PlayxNavigationSettings({
    this.navigatorKey,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.routingCallback,
    this.defaultTransition,
    this.getPages,
    this.opaqueRoute,
    this.customTransition,
    this.transitionDuration,
    this.defaultGlobalState,
    this.smartManagement = SmartManagement.full,
    this.initialBinding,
    this.unknownRoute,
  });
}


/// Default app settings
class PlayxAppSettings {
  final bool showPerformanceOverlay;
  final bool checkerboardRasterCacheImages;
  final bool checkerboardOffscreenLayers;
  final bool showSemanticsDebugger;
  final bool debugShowCheckedModeBanner;
  final bool debugShowMaterialGrid;
  final bool? enableLog;

  const PlayxAppSettings({
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = false,
    this.enableLog = kDebugMode,
  });
}

