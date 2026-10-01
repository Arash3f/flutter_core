import 'package:intl/intl.dart';

class FormatterDate {
  const FormatterDate();

  /// * Format [date] using the default pattern. Defaults to "now".
  String formatDate(DateTime? date) =>
      DateFormat('dd MMM yyyy').format(date ?? DateTime.now());

  /// * Format [date] with [format]
  String getFormattedDate(DateTime date, {String format = 'dd MMM yyyy'}) =>
      DateFormat(format).format(date);

  /// * Format [date] with the calendar and digits of [locale], e.g. `fa`.
  String getLocalizedDate(
    DateTime date, {
    String format = 'dd MMM yyyy',
    String? locale,
  }) => DateFormat(format, locale).format(date);
}
