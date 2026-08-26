import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_core/core/error/failure.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';

/// Turns any thrown object into a short, localized string for the UI.
///
/// Domain [Failure]s either carry a locale key (standard types) or a custom
/// key/[namedArgs] pair ([ValidationFailure]). Unknown errors never surface a
/// stack trace.
String describeError(Object error) => switch (error) {
      ValidationFailure(:final message, :final namedArgs) =>
        message.tr(namedArgs: namedArgs),
      CacheFailure() => LocaleKeys.errorCache.tr(),
      NetworkFailure() => LocaleKeys.errorNetwork.tr(),
      ServerFailure() => LocaleKeys.errorServer.tr(),
      UnexpectedFailure() => LocaleKeys.errorUnexpected.tr(),
      _ => LocaleKeys.errorUnexpected.tr(),
    };
