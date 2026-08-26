
# Logging Service

Wraps [logger](https://pub.dev/packages/logger). `logger.dart` is the only file
that imports the package, so replacing it later touches one file.

In release builds the level is raised to `warning`, so debug traces never reach
production logs. Use this instead of `print` — the `avoid_print` lint is on.

## Usage/Examples

```dart
import 'package:flutter_core/core/utils/logging/logger.dart';

/// debug message ?
LoggerService.debug('Test');

/// info message ?
LoggerService.info('Test');

/// warning message ?
LoggerService.warning('Test');

/// error ?
LoggerService.error('Could not load todos', error, stackTrace);
```

`error` takes an optional error object and stack trace. When no stack trace is
passed it falls back to `StackTrace.current`.
