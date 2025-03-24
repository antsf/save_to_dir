import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'save_to_dir_method_channel.dart';
import 'utils/typedef.dart';

abstract class SaveToDirPlatform extends PlatformInterface {
  /// Constructs a SaveToDirPlatform.
  SaveToDirPlatform() : super(token: _token);

  static final Object _token = Object();

  static SaveToDirPlatform _instance = MethodChannelSaveToDir();

  /// The default instance of [SaveToDirPlatform] to use.
  ///
  /// Defaults to [MethodChannelSaveToDir].
  static SaveToDirPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SaveToDirPlatform] when
  /// they register themselves.
  static set instance(SaveToDirPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool?> requestStoragePermission() {
    throw UnimplementedError(
        'requestStoragePermission() has not been implemented.');
  }

  void openStorageSettings() {
    throw UnimplementedError('openStorageSettings() has not been implemented.');
  }

  void openFileManager() {
    throw UnimplementedError('openStorageSettings() has not been implemented.');
  }

  Future<String?> saveFile(Uint8List imageBytes,
      {required String fileName, required String mimeType}) {
    throw UnimplementedError('saveToDir() has not been implemented.');
  }

  Future<void> downloadFromUrl(
    String url, {
    String? fileName,
    DownloadProgressCallback? onProgress,
    DownloadCompleteCallback? onComplete,
    DownloadErrorCallback? onError,
  }) {
    throw UnimplementedError('downloadFromUrl() has not been implemented.');
  }
}
