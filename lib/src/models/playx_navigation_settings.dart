import 'package:flutter/material.dart';
import 'package:playx_navigation/playx_navigation.dart';

/// Default navigation settings for Playx with support for both Navigator and Router.
///
/// The [PlayxNavigationSettings] class provides configuration options for navigation
/// within an application. It supports traditional [Navigator] and modern [Router] configurations,
/// as well as the [GoRouter] for advanced routing scenarios.
///
/// **Note:** The settings for Navigator, Router, and GoRouter are mutually exclusive.
/// Use only one of these configurations at a time.
class PlayxNavigationSettings {
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
  /// Applicable only for traditional [Navigator].
  /// For Router-based navigation, use the [RouterDelegate].
  final List<NavigatorObserver>? navigatorObservers;

  /// A builder function to wrap the entire navigation stack.
  final TransitionBuilder? builder;

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

  /// The [GoRouter] instance to use for advanced routing.
  final GoRouter? goRouter;

  /// Whether to include the Sentry navigator observer.
  /// Applicable only for traditional [Navigator].
  /// For Router-based navigation, add the Sentry observer to [RouterDelegate].
  final bool includeSentryNavigationObserver;

  /// Indicates whether to use Router-based navigation or GoRouter.
  final bool useRouter;


  /// Creates navigation settings for traditional [Navigator] navigation.
  ///
  /// This constructor sets up various properties related to Navigator-based navigation.
  const PlayxNavigationSettings({
    this.home,
    this.navigatorKey,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.includeSentryNavigationObserver = false,
  })  : useRouter = false,
        routeInformationProvider = null,
        routeInformationParser = null,
        routerDelegate = null,
        goRouter = null,
        backButtonDispatcher = null;

  /// Creates navigation settings that use the Router instead of Navigator.
  ///
  /// This constructor sets up various properties related to Router-based navigation.
  const PlayxNavigationSettings.router({
    this.routeInformationProvider,
    this.routeInformationParser,
    this.routerDelegate,
    this.backButtonDispatcher,
    this.navigatorKey,
    this.builder,
  })  : useRouter = true,
        routes = null,
        initialRoute = null,
        onGenerateRoute = null,
        onGenerateInitialRoutes = null,
        onUnknownRoute = null,
        goRouter = null,
        home = null,
        includeSentryNavigationObserver = false,
        navigatorObservers = null;

  /// Creates navigation settings that use the GoRouter instead of Navigator.
  ///
  /// This constructor sets up properties for advanced routing scenarios using [GoRouter].
  const PlayxNavigationSettings.goRouter({
    required GoRouter this.goRouter,
    this.navigatorKey,
    this.builder,
  })  : useRouter = true,
        routes = null,
        initialRoute = null,
        onGenerateRoute = null,
        onGenerateInitialRoutes = null,
        onUnknownRoute = null,
        routeInformationProvider = null,
        routeInformationParser = null,
        routerDelegate = null,
        backButtonDispatcher = null,
        navigatorObservers = null,
        includeSentryNavigationObserver = false,
        home = null;
}
