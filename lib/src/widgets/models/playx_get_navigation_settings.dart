import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Default navigation settings for Playx with support for both Navigator and Router.
///
/// The [PlayxGetNavigationSettings] class provides configuration options for navigation
/// within an application. It supports both traditional [Navigator] and modern [Router]
/// configurations, offering flexibility in how navigation is handled.
///
/// **Note:** The settings for Navigator and Router are mutually exclusive. Use either
/// Navigator-based settings or Router-based settings, but not both.
class PlayxGetNavigationSettings {
  /// Key for managing the [Navigator] state.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Map of route names to [WidgetBuilder] functions for traditional navigation.
  final Map<String, WidgetBuilder>? routes;

  /// The initial route to display when the app starts.
  final String? initialRoute;

  /// Function for generating routes for traditional navigation.
  final RouteFactory? onGenerateRoute;

  /// Function for generating initial routes for traditional navigation.
  final InitialRouteListFactory? onGenerateInitialRoutes;

  /// Function for handling unknown routes for traditional navigation.
  final RouteFactory? onUnknownRoute;

  /// List of [NavigatorObserver]s to observe navigation events.
  final List<NavigatorObserver>? navigatorObservers;

  /// A builder function to wrap the entire navigation stack.
  final TransitionBuilder? builder;

  /// Custom transition for route animations.
  final CustomTransition? customTransition;

  /// Duration for route transition animations.
  final Duration? transitionDuration;

  /// Flag indicating whether to use the default global state.
  final bool? defaultGlobalState;

  /// List of [GetPage] configurations for GetX-based navigation.
  final List<GetPage>? getPages;

  /// The route to display when an unknown route is accessed.
  final GetPage? unknownRoute;

  /// Callback function invoked during routing events.
  final ValueChanged<Routing?>? routingCallback;

  /// Default transition for GetX-based navigation.
  final Transition? defaultTransition;

  /// Whether the route should be opaque.
  final bool? opaqueRoute;

  /// Smart management strategy for GetX-based navigation.
  final SmartManagement smartManagement;

  /// Initial bindings for dependency injection.
  final Bindings? initialBinding;

  /// Default home widget for traditional navigation.
  final Widget? home;

  /// [RouteInformationProvider] for Router-based navigation.
  final RouteInformationProvider? routeInformationProvider;

  /// [RouteInformationParser] for Router-based navigation.
  final RouteInformationParser<Object>? routeInformationParser;

  /// [RouterDelegate] for Router-based navigation.
  final RouterDelegate<Object>? routerDelegate;

  /// [BackButtonDispatcher] for Router-based navigation.
  final BackButtonDispatcher? backButtonDispatcher;

  /// Whether to include the Sentry navigator observer.
  ///
  /// This option is applicable only when using [Navigator]. For [Router] based navigation,
  /// add the Sentry observer to [RouterDelegate].
  final bool includeSentryNavigationObserver;

  /// Whether to use Router-based navigation.
  final bool useRouter;

  /// Creates navigation settings for traditional [Navigator] navigation.
  ///
  /// This constructor sets up various properties related to Navigator-based navigation.
  const PlayxGetNavigationSettings({
    this.home,
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
    this.includeSentryNavigationObserver = true,
  })  : useRouter = false,
        routeInformationProvider = null,
        routeInformationParser = null,
        routerDelegate = null,
        backButtonDispatcher = null;

  /// Creates navigation settings for [Router] instead of [Navigator].
  ///
  /// This constructor sets up various properties related to Router-based navigation.
  const PlayxGetNavigationSettings.router({
    this.routeInformationProvider,
    this.routeInformationParser,
    this.routerDelegate,
    this.backButtonDispatcher,
    this.navigatorKey,
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
    this.navigatorObservers,
  })  : useRouter = true,
        routes = null,
        initialRoute = null,
        onGenerateRoute = null,
        onGenerateInitialRoutes = null,
        onUnknownRoute = null,
        unknownRoute = null,
        includeSentryNavigationObserver = true,
        home = null;
}
