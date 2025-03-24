# SaveToDir Plugin

The `SaveToDir` plugin provides functionality to save files to a specified directory on the device and download files from a URL with progress tracking and notifications. This plugin is designed to work seamlessly with Android and can be extended to support other platforms in the future.

## Features

- Save files to the device's storage.
- Download files from a URL with progress tracking.
- Show notifications for download progress and completion.
- Request storage permissions dynamically.

## Installation

To use the `SaveToDir` plugin, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  save_to_dir: ^.0.0.1
```

## Usage

To use the plugin, import it into your Dart code:

```dart
import 'package:save_to_dir/save_to_dir.dart';
```

### Save a File

You can save a file to the device's storage using the `saveToDir` method:

```dart
final saveToDir = SaveToDir();

Uint8List fileBytes = Uint8List.fromList([0, 1, 2, 3, 4, 5]); // Example data
String fileName = 'example_file.txt';
String mimeType = 'text/plain';

String? result = await saveToDir.saveToDir(
  fileBytes,
  fileName: fileName,
  mimeType: mimeType,
);

print(result ?? 'File saved successfully!');
```

### Download a File

You can download a file from a URL using the `downloadFromUrl` method with progress tracking:

```dart
final saveToDir = SaveToDir();

String url = 'https://example.com/sample.pdf';
String fileName = 'sample.pdf';

await saveToDir.downloadFromUrl(
  url,
  fileName: fileName,
  onProgressCallback: (downloadedBytes, totalBytes) {
    double progress = downloadedBytes / totalBytes;
    print('Download progress: ${(progress * 100).toStringAsFixed(2)}%');
  },
  onCompleteCallback: (uri) {
    print('Download complete: $uri');
  },
  onErrorCallback: (error) {
    print('Download failed: $error');
  },
);
```

### Request Storage Permission

You can request storage permissions dynamically:

```dart
bool? hasPermission = await saveToDir.requestStoragePermission();
if (hasPermission == true) {
  print('Storage permission granted');
} else {
  print('Storage permission denied');
}
```

### Open Storage Settings

You can open the device's storage settings:

```dart
await saveToDir.openStorageSettings();
```

## Example

Here is a complete example of how to use the `SaveToDir` plugin:

```dart
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:save_to_dir/save_to_dir.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _saveToDirPlugin = SaveToDir();
  String _downloadStatus = 'Idle';
  double _downloadProgress = 0.0;

  Future<void> saveFile() async {
    Uint8List fileBytes = Uint8List.fromList([0, 1, 2, 3, 4, 5]);
    String fileName = 'example_file.txt';
    String mimeType = 'text/plain';

    String? result = await _saveToDirPlugin.saveToDir(
      fileBytes,
      fileName: fileName,
      mimeType: mimeType,
    );

    print(result ?? 'File saved successfully!');
  }

  Future<void> downloadFile() async {
    String url = 'https://example.com/sample.pdf';
    String fileName = 'sample.pdf';

    setState(() {
      _downloadStatus = 'Downloading...';
      _downloadProgress = 0.0;
    });

    await _saveToDirPlugin.downloadFromUrl(
      url,
      fileName: fileName,
      onProgressCallback: (downloadedBytes, totalBytes) {
        setState(() {
          _downloadProgress = downloadedBytes / totalBytes;
        });
      },
      onCompleteCallback: (uri) {
        setState(() {
          _downloadStatus = 'Download complete: $uri';
        });
      },
      onErrorCallback: (error) {
        setState(() {
          _downloadStatus = 'Download failed: $error';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SaveToDir Plugin Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: saveFile,
                child: const Text('Save File'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: downloadFile,
                child: const Text('Download File'),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _downloadProgress,
                minHeight: 10,
              ),
              const SizedBox(height: 8),
              Text(_downloadStatus),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Contributing

Contributions are welcome! If you encounter any issues or have feature requests, feel free to open an issue or submit a pull request on [GitHub](https://github.com/antsf7/save_to_dir).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.