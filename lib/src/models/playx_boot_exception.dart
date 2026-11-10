/// Thrown when one of the Playx boot steps fails.
///
/// It tells which [step] failed (for example `Core`, `Localization`, `Theme`
/// or `AppConfig`) and keeps the original [error] and [stackTrace].
class PlayxBootException implements Exception {
  /// Name of the boot step that failed.
  final String step;

  /// The original error thrown by the step.
  final Object error;

  /// The stack trace of the original error.
  final StackTrace stackTrace;

  const PlayxBootException(this.step, this.error, this.stackTrace);

  @override
  String toString() => 'PlayxBootException: "$step" boot step failed: $error';
}
