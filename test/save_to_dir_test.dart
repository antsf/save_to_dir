import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:save_to_dir/save_to_dir.dart';
import 'package:save_to_dir/save_to_dir_platform_interface.dart';
import 'package:save_to_dir/save_to_dir_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:save_to_dir/utils/typedef.dart';

class MockSaveToDirPlatform
    with MockPlatformInterfaceMixin
    implements SaveToDirPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> saveFile(Uint8List imageBytes,
      {required String fileName, String? mimeType}) {
    return Future.value("File saved successfully");
  }

  @override
  Future<void> downloadFromUrl(
    String url, {
    String? fileName,
    DownloadProgressCallback? onProgress,
    DownloadCompleteCallback? onComplete,
    DownloadErrorCallback? onError,
  }) async {
    // Simulate download progress
    onProgress?.call(50, 100);
    await Future.delayed(Duration(seconds: 1));
    onProgress?.call(100, 100);
    onComplete?.call("Download completed");
  }

  @override
  Future<void> openStorageSettings() async {
    // Simulate opening storage settings
  }

  @override
  Future<bool?> requestStoragePermission() async {
    return Future.value(true);
  }

  @override
  void openFileManager() {
    throw UnimplementedError();
  }
}

void main() {
  final SaveToDirPlatform initialPlatform = SaveToDirPlatform.instance;

  test('$MethodChannelSaveToDir is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSaveToDir>());
  });

  test('getPlatformVersion', () async {
    SaveToDir saveToDirPlugin = SaveToDir();
    MockSaveToDirPlatform fakePlatform = MockSaveToDirPlatform();
    SaveToDirPlatform.instance = fakePlatform;

    expect(await saveToDirPlugin.getPlatformVersion(), '42');
  });

  test('saveToDir', () async {
    SaveToDir saveToDirPlugin = SaveToDir();
    MockSaveToDirPlatform fakePlatform = MockSaveToDirPlatform();
    SaveToDirPlatform.instance = fakePlatform;

    Uint8List imageBytes = Uint8List.fromList([0, 1, 2, 3, 4, 5]);
    String fileName = "test.png";
    String? mimeType = "image/png";

    expect(
        await saveToDirPlugin.saveToDir(imageBytes,
            fileName: fileName, mimeType: mimeType),
        "File saved successfully");
  });

  test('downloadFromUrl', () async {
    SaveToDir saveToDirPlugin = SaveToDir();
    MockSaveToDirPlatform fakePlatform = MockSaveToDirPlatform();
    SaveToDirPlatform.instance = fakePlatform;

    String url = "https://example.com/test.png";
    String fileName = "test.png";

    bool progressCalled = false;
    bool completeCalled = false;

    await saveToDirPlugin.downloadFromUrl(
      url,
      fileName: fileName,
      onProgressCallback: (downloadedBytes, totalBytes) {
        progressCalled = true;
        expect(downloadedBytes, anyOf(50, 100));
        expect(totalBytes, 100);
      },
      onCompleteCallback: (uri) {
        completeCalled = true;
        expect(uri, "Download completed");
      },
      onErrorCallback: (reason) {
        fail("Download failed with reason: $reason");
      },
    );

    expect(progressCalled, true);
    expect(completeCalled, true);
  });

  test('openStorageSettings', () {
    SaveToDir saveToDirPlugin = SaveToDir();
    MockSaveToDirPlatform fakePlatform = MockSaveToDirPlatform();
    SaveToDirPlatform.instance = fakePlatform;

    saveToDirPlugin.openStorageSettings();
    // No assertion needed as we are just simulating the method call
  });

  test('requestStoragePermission', () async {
    SaveToDir saveToDirPlugin = SaveToDir();
    MockSaveToDirPlatform fakePlatform = MockSaveToDirPlatform();
    SaveToDirPlatform.instance = fakePlatform;

    expect(await saveToDirPlugin.requestStoragePermission(), true);
  });
}
