import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:playx/src/widgets/getx/get_platform_app.dart';
import 'package:playx/src/models/playx_app_settings.dart';
import 'package:playx/src/models/playx_platform_settings.dart';
import 'package:playx/src/models/playx_screen_settings.dart';
import 'package:playx/src/models/playx_theme_settings.dart';
import 'package:playx_localization/playx_localization.dart';
import 'package:playx_theme/playx_theme.dart';
import 'package:playx_widget/playx_widget.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../models/playx_get_navigation_settings.dart';


///PlayxPlatformApp : A widget that wraps [GetMaterialApp] or [ GetCupertinoApp] based on the platform
///with [PlayXThemeBuilder] to update the app with current theme
///and [ScreenUtilInit] that initializes [ScreenUtil]
/// With the ability to set app orientation and more.
class PlayxGetPlatformApp extends StatelessWidget {
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
  final PlayxGetNavigationSettings navigationSettings;
  // App settings
  final PlayxAppSettings appSettings;

  //Get material app parameters
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final Widget? home;
  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final Color? color;
  final TextDirection? textDirection;
  final VoidCallback? onInit;
  final VoidCallback? onReady;
  final VoidCallback? onDispose;
  final LogWriterCallback? logWriterCallback;
  final bool? popGesture;

  const PlayxGetPlatformApp({
    super.key,
    this.preferredOrientations = const [
      DeviceOrientation.portraitUp,
    ],
    this.platformSettings = const PlayxPlatformSettings(),
    this.screenSettings = const PlayxScreenSettings(),
    this.themeSettings = const PlayxThemeSettings(),
    this.navigationSettings = const PlayxGetNavigationSettings(),
    this.appSettings = const PlayxAppSettings(),
    this.scaffoldMessengerKey,
    this.home,
    this.textDirection,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.onInit,
    this.onReady,
    this.onDispose,
    this.logWriterCallback,
    this.popGesture,
  });

  @override
  Widget build(BuildContext context) {
    return PlayxThemeBuilder(builder: (ctx, xTheme) {
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
            return PlayxLocalizationBuilder(builder: (ctx, locale) {
              return Theme(
                data: themeSettings.theme ??
                    xTheme.themeBuilder?.call(locale.locale) ??
                    xTheme.themeData,
                child: PlatformProvider(
                  initialPlatform: platformSettings.initialPlatform,
                  settings: PlatformSettingsData(
                    iosUsesMaterialWidgets:
                        platformSettings.iosUsesMaterialWidgets,
                    iosUseZeroPaddingForAppbarPlatformIcon:
                        platformSettings.iosUseZeroPaddingForAppbarPlatformIcon,
                    legacyIosUsesMaterialWidgets: false,
                    platformStyle: platformSettings.platformStyle,
                    wrapCupertinoAppBarMiddleWithMediaQuery: platformSettings
                        .wrapCupertinoAppBarMiddleWithMediaQuery,
                  ),
                  builder: (context) => navigationSettings.useRouter
                      ? GetPlatformApp.router(
                          theme: themeSettings.theme ??
                              xTheme.themeBuilder?.call(locale.locale) ??
                              xTheme.themeData,
                          cupertinoTheme: themeSettings.cupertinoTheme ??
                              xTheme.cupertinoThemeBuilder
                                  ?.call(locale.locale) ??
                              xTheme.cupertinoThemeData,
                          debugShowCheckedModeBanner:
                              appSettings.debugShowCheckedModeBanner,
                          scaffoldMessengerKey: scaffoldMessengerKey,
                          routeInformationProvider:
                              navigationSettings.routeInformationProvider,
                          routerDelegate: navigationSettings.routerDelegate,
                          routeInformationParser:
                              navigationSettings.routeInformationParser,
                          backButtonDispatcher:
                              navigationSettings.backButtonDispatcher,
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
                          debugShowMaterialGrid:
                              appSettings.debugShowMaterialGrid,
                          showPerformanceOverlay:
                              appSettings.showPerformanceOverlay,
                          checkerboardRasterCacheImages:
                              appSettings.checkerboardRasterCacheImages,
                          checkerboardOffscreenLayers:
                              appSettings.checkerboardOffscreenLayers,
                          showSemanticsDebugger:
                              appSettings.showSemanticsDebugger,
                          shortcuts: appSettings.shortcuts,
                          scrollBehavior: appSettings.scrollBehavior,
                          customTransition: navigationSettings.customTransition,
                          onInit: onInit,
                          onReady: onReady,
                          onDispose: onDispose,
                          routingCallback: navigationSettings.routingCallback,
                          defaultTransition:
                              navigationSettings.defaultTransition,
                          getPages: navigationSettings.getPages,
                          opaqueRoute: navigationSettings.opaqueRoute,
                          enableLog: appSettings.enableLog,
                          logWriterCallback: logWriterCallback,
                          popGesture: popGesture,
                          transitionDuration:
                              navigationSettings.transitionDuration,
                          defaultGlobalState:
                              navigationSettings.defaultGlobalState,
                          smartManagement: navigationSettings.smartManagement,
                          initialBinding: navigationSettings.initialBinding,
                          highContrastTheme: themeSettings.highContrastTheme,
                          highContrastDarkTheme:
                              themeSettings.highContrastDarkTheme,
                          actions: appSettings.actions,
                        )
                      : GetPlatformApp(
                          theme: themeSettings.theme ??
                              xTheme.themeBuilder?.call(locale.locale) ??
                              xTheme.themeData,
                          cupertinoTheme: themeSettings.cupertinoTheme ??
                              xTheme.cupertinoThemeBuilder
                                  ?.call(locale.locale) ??
                              xTheme.cupertinoThemeData,
                          debugShowCheckedModeBanner:
                              appSettings.debugShowCheckedModeBanner,
                          navigatorObservers:
                              navigationSettings.navigatorObservers ??
                                  [
                                    if (navigationSettings
                                        .includeSentryNavigationObserver)
                                      SentryNavigatorObserver(),
                                  ],
                          navigatorKey: navigationSettings.navigatorKey,
                          scaffoldMessengerKey: scaffoldMessengerKey,
                          home: home,
                          routes: navigationSettings.routes,
                          initialRoute: navigationSettings.initialRoute,
                          onGenerateRoute: navigationSettings.onGenerateRoute,
                          onGenerateInitialRoutes:
                              navigationSettings.onGenerateInitialRoutes,
                          onUnknownRoute: navigationSettings.onUnknownRoute,
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
                          debugShowMaterialGrid:
                              appSettings.debugShowMaterialGrid,
                          showPerformanceOverlay:
                              appSettings.showPerformanceOverlay,
                          checkerboardRasterCacheImages:
                              appSettings.checkerboardRasterCacheImages,
                          checkerboardOffscreenLayers:
                              appSettings.checkerboardOffscreenLayers,
                          showSemanticsDebugger:
                              appSettings.showSemanticsDebugger,
                          shortcuts: appSettings.shortcuts,
                          scrollBehavior: appSettings.scrollBehavior,
                          customTransition: navigationSettings.customTransition,
                          onInit: onInit,
                          onReady: onReady,
                          onDispose: onDispose,
                          routingCallback: navigationSettings.routingCallback,
                          defaultTransition:
                              navigationSettings.defaultTransition,
                          getPages: navigationSettings.getPages,
                          opaqueRoute: navigationSettings.opaqueRoute,
                          enableLog: appSettings.enableLog,
                          logWriterCallback: logWriterCallback,
                          popGesture: popGesture,
                          transitionDuration:
                              navigationSettings.transitionDuration,
                          defaultGlobalState:
                              navigationSettings.defaultGlobalState,
                          smartManagement: navigationSettings.smartManagement,
                          initialBinding: navigationSettings.initialBinding,
                          unknownRoute: navigationSettings.unknownRoute,
                          highContrastTheme: themeSettings.highContrastTheme,
                          highContrastDarkTheme:
                              themeSettings.highContrastDarkTheme,
                          actions: appSettings.actions,
                        ),
                ),
              );
            });
          });
    });
  }
}
