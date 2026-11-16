import 'dart:io';

import 'package:playx_core/secure_env_cli.dart';

/// Generates the encrypted secure env file.
///
/// `dart run playx:secure_env --help`
Future<void> main(List<String> arguments) async {
  exitCode = await runSecureEnvCli(arguments);
}
