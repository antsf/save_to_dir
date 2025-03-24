import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'save_to_dir_platform_interface.dart';
import 'utils/native_exception.dart';
import 'utils/typedef.dart';

/// An implementation of [SaveToDirPlatform] that uses method channels.
class MethodChannelSaveToDir extends SaveToDirPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('save_to_dir');

  Future<T?> _invokeMethod<T>(String method,
      [Map<String, dynamic>? args]) async {
    try {
      return await methodChannel.invokeMethod<T>(method, args);
    } on PlatformException catch (error, stackTrace) {
      throw NativeException.fromCode(
        code: error.code,
        platformException: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await _invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> requestStoragePermission() async {
    final status = await _invokeMethod<bool>('requestStoragePermission');
    return status;
  }

  @override
  void openStorageSettings() => _invokeMethod('openStorageSettings');

  @override
  void openFileManager() => _invokeMethod("openFileManager");

  @override
  Future<String?> saveFile(Uint8List imageBytes,
      {required String fileName, required String mimeType}) async {
    final result = await _invokeMethod<String>('saveFile', {
      'imageBytes': imageBytes,
      'fileName': fileName,
      'mimeType': mimeType,
    });
    return result;
  }

  @override
  Future<void> downloadFromUrl(
    String url, {
    String? fileName,
    DownloadProgressCallback? onProgress,
    DownloadCompleteCallback? onComplete,
    DownloadErrorCallback? onError,
  }) async {
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onProgressCallback':
          final bytes = call.arguments['bytes'] as int;
          final total = call.arguments['total'] as int;
          onProgress?.call(bytes, total);
          break;
        case 'onCompleteCallback':
          final downloadPath = call.arguments['downloadPath'] as String;
          onComplete?.call(downloadPath);
          break;
        case 'onErrorCallback':
          final error = call.arguments['error'] as String;
          onError?.call(error);
          break;
      }
    });

    await _invokeMethod('downloadFile', {
      'url': url,
      'fileName': fileName,
    });
  }
}
