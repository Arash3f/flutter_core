import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';

class ValidatorHelper {
  const ValidatorHelper._();

  /// ? Regular expression for email validation
  ///
  /// The TLD is unbounded on purpose; `{2,4}` rejected valid addresses such as
  /// `name@example.online`.
  static final RegExp _emailRegExp = RegExp(
    r'^[\w.+-]+@([\w-]+\.)+[A-Za-z]{2,}$',
  );

  /// ? Iranian mobile numbers: 11 digits starting with 09
  static final RegExp _phoneRegExp = RegExp(r'^09\d{9}$');

  /// * Validate Empty Text
  static String? validateEmptyText({
    required String? value,
    required String fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.inputRequired.tr(namedArgs: {'fieldName': fieldName});
    }
    return null;
  }

  /// * Validate Email Empty & format
  static String? validateEmail(String? value) {
    final fieldName = LocaleKeys.email.tr();

    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.inputRequired.tr(namedArgs: {'fieldName': fieldName});
    }

    if (!_emailRegExp.hasMatch(value.trim())) {
      return LocaleKeys.invalidInput.tr(namedArgs: {'fieldName': fieldName});
    }

    return null;
  }

  /// * Validate Password Empty & format
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.inputRequired.tr(
        namedArgs: {'fieldName': LocaleKeys.password.tr()},
      );
    }

    /// ? Check for minimum password length
    if (value.length < 6) {
      return LocaleKeys.passwordMustBeAtLeast6CharactersLong.tr();
    }

    /// ? Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return LocaleKeys.passwordMustContainAtLeastOneUppercaseLetter.tr();
    }

    /// ? Check for numbers
    if (!value.contains(RegExp(r'\d'))) {
      return LocaleKeys.passwordMustContainAtLeastOneNumber.tr();
    }

    /// ? Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return LocaleKeys.passwordMustContainAtLeastOneSpecialCharacter.tr();
    }

    return null;
  }

  /// * Validate PhoneNumber
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.inputRequired.tr(
        namedArgs: {'fieldName': LocaleKeys.phoneNumber.tr()},
      );
    }

    if (!_phoneRegExp.hasMatch(value.trim())) {
      return LocaleKeys.invalidPhoneNumberFormat.tr();
    }

    return null;
  }
}
