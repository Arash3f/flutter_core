import 'package:flutter/widgets.dart';

enum LanguageList {
  english('en', 'English'),
  persian('fa', 'فارسی');

  const LanguageList(this.code, this.label);

  /// ISO 639-1 code. Must match a file name in `assets/translations`.
  final String code;

  /// Name shown to the user, written in the language itself.
  final String label;

  Locale get locale => Locale(code);

  static const List<Locale> supportedLocales = [Locale('en'), Locale('fa')];

  static LanguageList fromCode(String? code) => values.firstWhere(
        (language) => language.code == code,
        orElse: () => persian,
      );
}
