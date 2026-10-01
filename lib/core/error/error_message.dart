import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_core/core/error/failure.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';

/// Turns any thrown object into a short, localized string for the UI.
///
/// Domain [Failure]s either carry a locale key (standard types) or a custom
/// key/[namedArgs] pair ([ValidationFailure]). Backend messages
/// ([ApiFailure]) are shown verbatim when they read like a sentence and
/// translated when they look like a key. Unknown errors never surface a stack
/// trace.
String describeError(Object error) => switch (error) {
  ValidationFailure(:final message, :final namedArgs) => message.tr(
    namedArgs: namedArgs,
  ),
  ApiFailure(:final message, :final namedArgs) =>
    _isSentence(message) ? message : message.tr(namedArgs: namedArgs),
  AuthFailure() => LocaleKeys.errorAuth.tr(),
  CacheFailure() => LocaleKeys.errorCache.tr(),
  NetworkFailure() => LocaleKeys.errorNetwork.tr(),
  ServerFailure(:final message) =>
    _isSentence(message) ? message : LocaleKeys.errorServer.tr(),
  UnexpectedFailure() => LocaleKeys.errorUnexpected.tr(),
  _ => LocaleKeys.errorUnexpected.tr(),
};

/// Locale keys are single camelCase tokens; anything with a space came from a
/// human (usually the backend) and is already readable.
bool _isSentence(String message) => message.trim().contains(' ');
