import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Every [Exception] that [Native] throws should be this.
@immutable
class NativeException implements Exception {
  const NativeException({
    required this.type,
    required this.platformException,
    required this.stackTrace,
  });

  /// Type of error.
  ///
  /// See: [NativeExceptionType]
  final NativeExceptionType type;

  /// Native code error information.
  final PlatformException platformException;

  /// Stack trace of the error in dart side.
  ///
  /// The native code StackTrace is stored in [PlatformException.stacktrace].
  final StackTrace stackTrace;

  factory NativeException.fromCode({
    required String code,
    required PlatformException platformException,
    required StackTrace stackTrace,
  }) {
    final type = NativeExceptionType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => NativeExceptionType.unexpected,
    );
    return NativeException(
      type: type,
      platformException: platformException,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() => "[NativeException/${type.code}]: ${type.message}";
}

/// Types of [NativeException]
///
/// If the type cannot be determined, it will be [unexpected].
/// In that case, you can get support by submitting
/// an [issue](https://github.com/natsuk4ze/gal/issues)
/// including all values of [NativeException.platformException]
/// and [NativeException.stackTrace].
enum NativeExceptionType {
  /// When has no permission to access gallery app.
  /// See: https://github.com/natsuk4ze/gal/wiki/Permissions
  accessDenied,

  /// When insufficient device storage.
  notEnoughSpace,

  /// When trying to save a file in an unsupported format.
  /// See: https://github.com/natsuk4ze/gal/wiki/Formats
  notSupportedFormat,

  /// When an error occurs with unexpected.
  unexpected;

  String get code => switch (this) {
        accessDenied => 'ACCESS_DENIED',
        notEnoughSpace => 'NOT_ENOUGH_SPACE',
        notSupportedFormat => 'NOT_SUPPORTED_FORMAT',
        unexpected => 'UNEXPECTED',
      };

  String get message => switch (this) {
        accessDenied => 'Permission to access the gallery is denied.',
        notEnoughSpace => 'Not enough space for storage.',
        notSupportedFormat => 'Unsupported file formats.',
        unexpected => 'An unexpected error has occurred.',
      };
}
