import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Prefs {
  static SharedPreferences get _prefs => Get.find<SharedPreferences>();

  static String? getString(
    String key,
  ) =>
      _prefs.getString(key);

  static Future<void> setString(
    String key,
    String value,
  ) =>
      _prefs.setString(key, value);

  static int? getInt(
    String key,
  ) =>
      _prefs.getInt(key);

  static Future<void> setInt(
    String key,
    int value,
  ) =>
      _prefs.setInt(key, value);

  static bool getBool(
    String key,
  ) =>
      _prefs.getBool(key) ?? false;

  static Future<void> setBool(
    String key,
    bool value,
  ) =>
      _prefs.setBool(key, value);

  static Object? find(
    String key,
  ) =>
      _prefs.get(key);

  /// clear the preferences
  static Future<void> clear() => _prefs.clear();

  static Future<void> remove(
    String key,
  ) =>
      _prefs.remove(key);
}
