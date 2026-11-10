# Connection status

`ConnectionStatusController` is a `ValueNotifier<ConnectionStatus>` that tells you whether the
device is online, and shows a short "back online" state after a reconnect.

```dart
final controller = ConnectionStatusController();

ValueListenableBuilder<ConnectionStatus>(
  valueListenable: controller,
  builder: (context, status, _) => switch (status) {
    ConnectionStatus.connected => const SizedBox.shrink(),
    ConnectionStatus.disconnected => const Banner(text: 'You are offline'),
    ConnectionStatus.connectionRestored => const Banner(text: 'Back online'),
  },
);

// Don't forget to release it.
controller.dispose();
```

## Statuses

| Status | Meaning |
| --- | --- |
| `connected` | The device is connected (the initial value). |
| `disconnected` | The device is offline. |
| `connectionRestored` | Connection came back; shown for `backOnlineDelay`, then becomes `connected`. |

## Check types

`ConnectionCheckType` chooses what is checked:

| Type | Checks | Use for |
| --- | --- | --- |
| `both` | Device network **and** real internet access (pings URLs). Default on mobile/desktop. | Most apps. |
| `internet` | Pings URLs only. On web the URLs must support CORS. | When network type doesn't matter. |
| `device` | Only the device network (`connectivity_plus`). Default on **web**. | Web, to avoid CORS and extra pings. |

## Options

```dart
ConnectionStatusController(
  checkType: ConnectionCheckType.both,
  enableChecking: true,                        // start monitoring immediately
  checkInterval: const Duration(seconds: 5),   // time between internet checks
  backOnlineDelay: const Duration(seconds: 2), // how long connectionRestored is shown
  customCheckOptions: [
    InternetCheckOption(uri: Uri.parse('https://example.com/health')),
  ],
);
```

## Methods and getters

- `isConnected` — `true` unless the status is `disconnected`.
- `checkInternetConnection()` — check now and update the value.
- `setCheckingEnabled(bool)` — start or stop monitoring at runtime.
- `listenToConnectionStatus()` / `stopListeningToConnectionStatus()` — manual control.
- The controller pauses when the app goes to the background and resumes in the foreground.
- After `dispose()` the controller ignores late results, so a pending "back online" delay can't crash.
