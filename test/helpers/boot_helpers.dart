import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx/playx.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// An app config that records its lifecycle calls.
class FakeAppConfig extends PlayXAppConfig {
  final List<String> calls;
  final Object? bootError;
  final Object? asyncBootError;
  final Future<void>? asyncBootGate;

  FakeAppConfig(
    this.calls, {
    this.bootError,
    this.asyncBootError,
    this.asyncBootGate,
  });

  @override
  Future<void> boot() async {
    calls.add('boot');
    if (bootError != null) throw bootError!;
  }

  @override
  Future<void> asyncBoot() async {
    calls.add('asyncBoot');
    await asyncBootGate;
    if (asyncBootError != null) throw asyncBootError!;
  }

  @override
  Future<void> dispose() async {
    calls.add('dispose');
  }
}

PlayxThemeConfig fakeThemeConfig() => PlayxThemeConfig(
  saveTheme: false,
  themes: [
    XTheme(id: 'light', name: 'Light', themeData: ThemeData.light()),
    XTheme(id: 'dark', name: 'Dark', themeData: ThemeData.dark()),
  ],
);

PlayxLocaleConfig fakeLocaleConfig() => PlayxLocaleConfig(
  path: 'assets/translations',
  supportedLocales: const [
    XLocale(id: 'en', name: 'English', languageCode: 'en'),
  ],
  fallbackLocale: const XLocale(id: 'en', name: 'English', languageCode: 'en'),
);

/// Mocks the platform pieces that booting Playx relies on.
void mockBootPlatform() {
  SharedPreferences.setMockInitialValues({});
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        if (key.startsWith('assets/translations/')) {
          return ByteData.sublistView(
            Uint8List.fromList(utf8.encode(jsonEncode({'hello': 'Hello'}))),
          );
        }
        if (key == 'assets/env/test.env') {
          return ByteData.sublistView(
            Uint8List.fromList(utf8.encode('API_KEY=secret\n')),
          );
        }
        return null;
      });
}

const testSecurePrefsSettings = PlayxSecurePrefsSettings(
  createSecurePrefs: false,
);
const testWorkManagerSettings = WorkManagerSettings(initWorkerManager: false);
const testPrefsSettings = PlayxPrefsSettings();
