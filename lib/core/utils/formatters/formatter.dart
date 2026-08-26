import 'package:flutter_core/core/utils/formatters/_formatter_date.dart';

/// Namespace for the formatter families, so call sites read as
/// `Formatter.date.formatDate(...)`.
class Formatter {
  const Formatter._();

  static const FormatterDate date = FormatterDate();
}
