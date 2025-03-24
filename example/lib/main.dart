import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
  String _platformVersion = 'Unknown';
  String _downloadStatus = 'Idle';
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Initialize platform state
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _saveToDirPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } catch (e) {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  // Save a file to the device
  Future<void> saveFile() async {
    try {
      Uint8List fileBytes =
          Uint8List.fromList([0, 1, 2, 3, 4, 5]); // Example data
      String fileName = 'example_file.txt';
      String mimeType = 'text/plain';

      String? result = await _saveToDirPlugin.saveToDir(
        fileBytes,
        fileName: fileName,
        mimeType: mimeType,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result ?? 'File saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save file: $e')),
      );
    }
  }

  // Download a file from a URL
  Future<void> downloadFile() async {
    String url = 'https://example.com/sample.pdf';
    String fileName = 'sample.pdf';

    setState(() {
      _downloadStatus = 'Downloading...';
      _downloadProgress = 0.0;
    });

    try {
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
    } catch (e) {
      setState(() {
        _downloadStatus = 'Download failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SaveToDir Plugin Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
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
