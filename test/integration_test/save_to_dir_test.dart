import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:save_to_dir/save_to_dir.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SaveToDirPlugin Integration Tests', () {
    testWidgets('Test storage permission request', (WidgetTester tester) async {
      // app.main();
      await tester.pumpAndSettle();

      // Trigger permission request
      final permissionResult =
          await SaveToDir.instance.requestStoragePermission();
      expect(permissionResult, isTrue);
    });

    testWidgets('Test save file with permission', (WidgetTester tester) async {
      // app.main();
      await tester.pumpAndSettle();

      // Mock file data
      final imageBytes = Uint8List.fromList([0, 1, 2, 3, 4]);
      final fileName = 'test.png';
      final mimeType = 'image/png';

      // Save file
      final result = await SaveToDir.instance.saveFile(
        imageBytes,
        fileName: fileName,
        mimeType: mimeType,
      );
      expect(result, isNotNull);
    });

    testWidgets('Test download file with permission',
        (WidgetTester tester) async {
      main();
      await tester.pumpAndSettle();

      // Mock download URL
      final url = 'https://example.com/file.png';
      final fileName = 'file.png';

      // Download file
      await SaveToDir.instance.downloadFromUrl(
        url,
        fileName: fileName,
      );
      // expect(downloadId, isNotNull);
    });
  });
}
