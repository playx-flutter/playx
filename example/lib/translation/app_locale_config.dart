import 'package:playx/playx.dart';

PlayxLocaleConfig createLocaleConfig() {
  final locales = [
    const XLocale(id: 'en', name: 'English', languageCode: 'en'),
    const XLocale(id: 'ar', name: 'العربية', languageCode: 'ar'),
  ];
  return PlayxLocaleConfig(
    path: 'assets/translations',
    supportedLocales: [
      const XLocale(id: 'en', name: 'English', languageCode: 'en'),
      const XLocale(id: 'ar', name: 'العربية', languageCode: 'ar'),
    ],
    startLocale: null,
    fallbackLocale: locales[0],
  );
}
