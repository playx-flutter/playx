# Exports

`import 'package:playx/playx.dart';` re-exports the following. You don't need to add these
packages to your own `pubspec.yaml`.

| Package | Notes |
| --- | --- |
| `playx_core` | Via the other Playx packages: `PlayxCore`, `PlayxPrefs`, `PlayxSecurePrefs`, `PlayxEnv`, `PlayxLogger`, extensions. See [playx_core](packages/playx_core.md). |
| `playx_theme` | `PlayxTheme`, `PlayxThemeConfig`, `XTheme`, `PlayxThemeBuilder`. |
| `playx_localization` | `PlayxLocalization`, `XLocale`, `.tr()`. `TextDirection` is hidden to avoid a clash with Flutter's. |
| `playx_navigation` | `PlayxNavigation`, `PlayxRoute`, `PlayxBinding`, and `go_router`. |
| `playx_network` | `PlayxNetworkClient`, `NetworkResult`, `Dio`. |
| `playx_widget` | Utility widgets, `flutter_screenutil`, `flutter_svg`, `lottie`, ... |
| `get` | GetX. `FormData`, `Response`, `MultipartFile`, `GetNumUtils`, `Translations`, `GetConnect`, `GetSocket`, `Trans` and `ContextExtensionss` are hidden to avoid clashes with Dio and others. |
| `async` | `Result` is hidden to avoid a clash with other result types. |
| `connectivity_plus` | `Connectivity`, `ConnectivityResult`. |
| `internet_connection_checker_plus` | `InternetConnection`, `InternetCheckOption`. |
| `flutter_animate` | Animation helpers. |
| `queen_validators` | Form validators. |
| `sentry_flutter` | An explicit list of public APIs (see below). |

Playx also adds:

- `Playx`, `PlayXAppConfig`, `PlayxBootException`
- `PlayxMaterialApp`, `PlayxPlatformApp`, `PlayxGetMaterialApp`, `PlayxGetPlatformApp`, `GetPlatformApp`
- `PlayxAppSettings`, `PlayxScreenSettings`, `PlayxThemeSettings`, `PlayxNavigationSettings`,
  `PlayxGetNavigationSettings`, `PlayxPlatformSettings`, `PlayxWebSettings`
- `ConnectionStatusController`, `ConnectionStatus`, `ConnectionCheckType`
- `AreEqual` and `AreNotEqual` validators for matching fields (for example "confirm password").

## Sentry

`sentry_flutter` is exported with an explicit `show` list (for example `Sentry`,
`SentryFlutter`, `SentryFlutterOptions`, `SentryEvent`, `SentryLevel`, `Breadcrumb`,
`SentryUser`, `Scope`, `Hint`, `SentryNavigatorObserver`, `SentryAssetBundle`, `SentryReplay*`
and the widgets for masking and screenshots). Listing names explicitly means a new Sentry
release can't break the export. If you need an API that isn't listed, import it directly:

```dart
import 'package:sentry_flutter/sentry_flutter.dart';
```

## `AreEqual` / `AreNotEqual`

```dart
final password = TextEditingController();

TextFormField(
  validator: qValidator([
    AreEqual(other: () => password.text, errorMsg: 'Passwords do not match'),
  ]),
);
```

Both take `caseSensitive` (default `true`) and read `other` lazily on each validation.

## `dart run playx:secure_env`

`playx` exposes the `secure_env` command of `playx_core`, which encrypts sensitive env
values into a Dart file. See [playx_core](packages/playx_core.md#secure-env).
