# App info

`AppInfoNotifier` loads the app's `PackageInfo` once and lets you read or listen to it anywhere.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInfoNotifier.instance.load(); // optional: preload
  runApp(const MyApp());
}
```

## `AppInfo`

| Field | Description |
|---|---|
| `appName` | App name |
| `packageName` | Package name / bundle id |
| `version` | Version name, e.g. `1.2.3` |
| `buildNumber` | Build number / version code |
| `buildSignature` | Build signature (Android only) |
| `installerStore` | Store the app was installed from, when known |

`info.format(prefix: 'v', showVersionCode: true)` returns e.g. `v1.2.3+42`.

## Reading and listening

```dart
final info = AppInfoNotifier.instance.value; // null until loaded
final loaded = await AppInfoNotifier.instance.load(); // cached after first call

ValueListenableBuilder<AppInfo?>(
  valueListenable: AppInfoNotifier.instance,
  builder: (context, info, _) => Text(info?.packageName ?? ''),
);
```

- `load()` reads `PackageInfo` once; `load(force: true)` reloads.
- A failed load can be retried.
- Listeners are only notified when the info actually changes.

## `AppVersion` widget

```dart
const AppVersion(prefix: 'v', showVersionCode: true);

// Over an image: white text with a black outline.
const AppVersion(showStroke: true);
```

Options: `prefix`, `postfix`, `showVersionCode`, `versionCodeSeparator`, `textStyle`, `fontSize`,
`fontWeight`, `fontFamily`, `color`, `textAlign`, `showStroke`, `strokeColor`, `notifier`.

## Testing

Pass your own notifier and mock `PackageInfo`:

```dart
PackageInfo.setMockInitialValues(
  appName: 'app', packageName: 'io.test', version: '1.2.3',
  buildNumber: '42', buildSignature: '',
);
await tester.pumpWidget(MaterialApp(
  home: AppVersion(notifier: AppInfoNotifier(), textStyle: const TextStyle()),
));
```

---

*Imported from the [playx_widget 0.6.0 documentation](https://github.com/playx-flutter/playx_widget/blob/main/doc/app-info.md). [Package site](https://playx-flutter.github.io/playx_widget/) · [pub.dev](https://pub.dev/packages/playx_widget).*
