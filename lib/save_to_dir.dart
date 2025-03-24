// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:typed_data';

import 'save_to_dir_platform_interface.dart';
import 'utils/typedef.dart';

class SaveToDir {
  static SaveToDirPlatform get instance => SaveToDirPlatform.instance;

  Future<String?> getPlatformVersion() =>
      SaveToDirPlatform.instance.getPlatformVersion();

  Future<bool?> requestStoragePermission() =>
      SaveToDirPlatform.instance.requestStoragePermission();

  void openStorageSettings() =>
      SaveToDirPlatform.instance.openStorageSettings();

  void openFileManager() => SaveToDirPlatform.instance.openFileManager();

  Future<String?> saveToDir(Uint8List imageBytes,
          {required String fileName, required String mimeType}) async =>
      await SaveToDirPlatform.instance
          .saveFile(imageBytes, fileName: fileName, mimeType: mimeType);

  Future<void> downloadFromUrl(
    String url, {
    String? fileName,
    DownloadProgressCallback? onProgressCallback,
    DownloadCompleteCallback? onCompleteCallback,
    DownloadErrorCallback? onErrorCallback,
  }) async =>
      await SaveToDirPlatform.instance.downloadFromUrl(
        url,
        fileName: fileName,
        onProgress: onProgressCallback,
        onComplete: onCompleteCallback,
        onError: onErrorCallback,
      );
}
