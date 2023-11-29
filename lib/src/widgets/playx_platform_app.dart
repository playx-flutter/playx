import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playx/src/widgets/get_platform_app.dart';
import 'package:playx/src/widgets/models/playx_app_settings.dart';
import 'package:playx/src/widgets/models/playx_navigation_settings.dart';
import 'package:playx/src/widgets/models/playx_platform_settings.dart';
import 'package:playx/src/widgets/models/playx_screen_settings.dart';
import 'package:playx/src/widgets/models/playx_theme_settings.dart';
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
  /// platform widgets settings
  final PlayxPlatformSettings platformSettings;
  /// Screen util settings
  final PlayxScreenSettings screenSettings;
  // App theme settings
  final PlayxThemeSettings themeSettings;
  // App navigation settings
  final PlayxNavigationSettings navigationSettings;
  // App settings
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
              return Theme(
                data: xTheme.theme(locale.locale),
                child: PlatformProvider(
                  initialPlatform: platformSettings.initialPlatform,
                  settings: PlatformSettingsData(
                    iosUsesMaterialWidgets:platformSettings.iosUsesMaterialWidgets,
                    iosUseZeroPaddingForAppbarPlatformIcon :platformSettings.iosUseZeroPaddingForAppbarPlatformIcon,
                    legacyIosUsesMaterialWidgets : false,
                    platformStyle :platformSettings.platformStyle,
                    wrapCupertinoAppBarMiddleWithMediaQuery :platformSettings.wrapCupertinoAppBarMiddleWithMediaQuery,
                  ),
                  builder: (context) =>navigationSettings.useRouter? GetPlatformApp.router(
                    theme: themeSettings.theme ?? xTheme.theme(locale.locale),
                    cupertinoTheme: themeSettings.cupertinoTheme ?? xTheme.cupertinoTheme?.call(locale.locale),
                    debugShowCheckedModeBanner: appSettings.debugShowCheckedModeBanner,
                    scaffoldMessengerKey: scaffoldMessengerKey,
                    routeInformationProvider: navigationSettings.routeInformationProvider,
                    routerDelegate: navigationSettings.routerDelegate,
                    routeInformationParser: navigationSettings.routeInformationParser,
                    backButtonDispatcher: navigationSettings.backButtonDispatcher,
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
                    highContrastTheme: themeSettings.highContrastTheme,
                    highContrastDarkTheme: themeSettings.highContrastDarkTheme,
                    actions: actions,

                  ) :  GetPlatformApp(
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
                ),
              );
            });
          });
    });
  }
}














