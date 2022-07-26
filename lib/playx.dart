library playx;

import 'package:flutter/cupertino.dart';

import 'utils/prefs.dart';

export 'exports.dart';

Future<void> bootPlayX({
  required Widget app,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
}
