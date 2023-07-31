import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playx_localization/playx_localization.dart';
import 'package:playx_theme/playx_theme.dart';
import 'package:playx_widget/playx_widget.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

///PlayxMaterialApp : A widget that wraps [GetMaterialApp] with [PlayXThemeBuilder] to update the app with current theme  and [ScreenUtilInit] that initializes [ScreenUtil]
/// With the ability to set app orientation and more.
class PlayxMaterialApp extends StatelessWidget {

  //orientation
  /// Sets your preferred orientations of the Material app.
  final List<DeviceOrientation> preferredOrientations;

  //Screen Util parameters:
  final Size designSize;
  final bool splitScreenMode;
  final bool minTextAdapt;
  final bool useInheritedMediaQuery;
  final bool scaleByHeight;
  final RebuildFactor rebuildFactor;

  //Get material app parameters
  final GlobalKey<NavigatorState>? navigatorKey;

  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final Widget? home;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final InitialRouteListFactory? onGenerateInitialRoutes;
  final RouteFactory? onUnknownRoute;
  final List<NavigatorObserver>? navigatorObservers;
  final TransitionBuilder? builder;
  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;
  final CustomTransition? customTransition;
  final Color? color;
  final Map<String, Map<String, String>>? translationsKeys;
  final TextDirection? textDirection;
  final bool showPerformanceOverlay;
  final bool checkerboardRasterCacheImages;
  final bool checkerboardOffscreenLayers;
  final bool showSemanticsDebugger;
  final bool debugShowCheckedModeBanner;
  final Map<LogicalKeySet, Intent>? shortcuts;
  final ScrollBehavior? scrollBehavior;
  final ThemeData? highContrastTheme;
  final ThemeData? highContrastDarkTheme;
  final Map<Type, Action<Intent>>? actions;
  final bool debugShowMaterialGrid;
  final ValueChanged<Routing?>? routingCallback;
  final Transition? defaultTransition;
  final bool? opaqueRoute;
  final VoidCallback? onInit;
  final VoidCallback? onReady;
  final VoidCallback? onDispose;
  final bool? enableLog;
  final LogWriterCallback? logWriterCallback;
  final bool? popGesture;
  final SmartManagement smartManagement;
  final Bindings? initialBinding;
  final Duration? transitionDuration;
  final bool? defaultGlobalState;
  final List<GetPage>? getPages;
  final GetPage? unknownRoute;
  ///Whether should include sentry navigator observer or not..
  final bool includeSentryNavigationObserver;
  ///Callback that is called when the theme is updated.
  final Function(XTheme)? onThemeChanged;


  const PlayxMaterialApp({super.key, this.preferredOrientations = const[
    DeviceOrientation.portraitUp,
  ],
    this.onThemeChanged,
    this.splitScreenMode = true,
    this.minTextAdapt = true,
    this.useInheritedMediaQuery = false,
    this.scaleByHeight = false,
    this.rebuildFactor = RebuildFactors.size,
    this.designSize = const Size(360, 690),
    this.navigatorKey,
    this.scaffoldMessengerKey,
    this.home,
    this.routes =
    const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.textDirection,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = false,
    this.shortcuts,
    this.scrollBehavior,
    this.customTransition,
    this.translationsKeys,
    this.onInit,
    this.onReady,
    this.onDispose,
    this.routingCallback,
    this.defaultTransition,
    this.getPages,
    this.opaqueRoute,
    this.enableLog = kDebugMode,
    this.logWriterCallback,
    this.popGesture,
    this.transitionDuration,
    this.defaultGlobalState,
    this.smartManagement = SmartManagement.full,
    this.initialBinding,
    this.unknownRoute,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.actions,
    this.includeSentryNavigationObserver = true,
  });

  @override
  Widget build(BuildContext context) {
    return PlayXThemeBuilder(
        builder: (xTheme) {
          onThemeChanged?.call(xTheme);
          SystemChrome.setPreferredOrientations(preferredOrientations);
          return ScreenUtilInit(
              designSize: designSize,
              minTextAdapt: minTextAdapt,
              splitScreenMode: splitScreenMode,
              useInheritedMediaQuery: useInheritedMediaQuery,
              scaleByHeight: scaleByHeight,
              rebuildFactor: rebuildFactor,
              builder: (context, child) {
                return PlayxLocalizationBuilder(
                  builder: (locale) {
                    return GetMaterialApp(
                      theme: theme ?? xTheme.theme(locale.locale),
                      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
                      navigatorObservers: navigatorObservers ?? [
                        if(includeSentryNavigationObserver) SentryNavigatorObserver(),
                      ],
                      navigatorKey: navigatorKey,
                      scaffoldMessengerKey: scaffoldMessengerKey,
                      home: home,
                      routes: routes,
                      initialRoute: initialRoute,
                      onGenerateRoute: onGenerateRoute,
                      onGenerateInitialRoutes: onGenerateInitialRoutes,
                      onUnknownRoute: onUnknownRoute,
                      builder: builder,
                      textDirection: textDirection,
                      title: title,
                      onGenerateTitle: onGenerateTitle,
                      color: color,
                      darkTheme: darkTheme,
                      themeMode: themeMode,
                      supportedLocales: PlayxLocalization.supportedLocales,
                      localizationsDelegates: PlayxLocalization
                          .localizationDelegates,
                      locale: PlayxLocalization.currentLocale,
                      debugShowMaterialGrid: debugShowMaterialGrid,
                      showPerformanceOverlay: showPerformanceOverlay,
                      checkerboardRasterCacheImages: checkerboardRasterCacheImages,
                      checkerboardOffscreenLayers: checkerboardOffscreenLayers,
                      showSemanticsDebugger: showSemanticsDebugger,
                      shortcuts: shortcuts,
                      scrollBehavior: scrollBehavior,
                      customTransition: customTransition,
                      translationsKeys: translationsKeys,
                      onInit: onInit,
                      onReady: onReady,
                      onDispose: onDispose,
                      routingCallback: routingCallback,
                      defaultTransition: defaultTransition,
                      getPages: getPages,
                      opaqueRoute: opaqueRoute,
                      enableLog: enableLog,
                      logWriterCallback: logWriterCallback,
                      popGesture: popGesture,
                      transitionDuration: transitionDuration,
                      defaultGlobalState: defaultGlobalState,
                      smartManagement: smartManagement,
                      initialBinding: initialBinding,
                      unknownRoute: unknownRoute,
                      highContrastTheme: highContrastTheme,
                      highContrastDarkTheme: highContrastDarkTheme,
                      actions: actions,
                    );
                  }
                );
              });
        });
  }
}

