import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasa_me/storage/data_deletion_service.dart';
import 'package:kasa_me/storage/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';

void main() {
  group('Phase 20 - DataDeletionService Security P0 Test', () {
    late Directory tempRoot;
    late DataDeletionService service;
    late AppDatabase database;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Create isolated temp root
      tempRoot = await Directory.systemTemp.createTemp('kasa_me_test_root_');
      
      final docsDir = Directory('${tempRoot.path}/app_data/documents');
      final tempDir = Directory('${tempRoot.path}/app_data/temp');
      await docsDir.create(recursive: true);
      await tempDir.create(recursive: true);
      
      // Add a dummy file to prove deletion succeeds
      final file1 = File('${docsDir.path}/user_profile.json');
      await file1.writeAsString('{"id": 1}');
      
      // Setup Mock MethodChannels
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return docsDir.path;
        }
        if (methodCall.method == 'getTemporaryDirectory') {
          return tempDir.path;
        }
        return null;
      });
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'), (MethodCall methodCall) async {
        return null;
      });

      database = AppDatabase(NativeDatabase.memory());
      
      service = DataDeletionService(
        database: database,
      );
    });

    tearDown(() async {
      await database.close();
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('Legitimate application-owned deletion succeeds', () async {
      final docsDir = Directory('${tempRoot.path}/app_data/documents');
      expect(await File('${docsDir.path}/user_profile.json').exists(), isTrue);
      
      await service.deleteAllLocalData();
      
      // the docs directory itself remains, but its contents should be cleared
      expect(await File('${docsDir.path}/user_profile.json').exists(), isFalse);
    });

    test('Mocks returning dangerous paths are safely rejected without destroying the system', () async {
      // Create a dummy file outside to represent system state
      final outsideFile = File('${tempRoot.path}/precious_system_file.txt');
      await outsideFile.writeAsString('keep me');
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return '.'; // DANGEROUS!
        }
        if (methodCall.method == 'getTemporaryDirectory') {
          return '/'; // DANGEROUS!
        }
        return null;
      });

      // Try deletion. It should gracefully reject . and / and not crash or wipe.
      await service.deleteAllLocalData();
      
      // The dangerous paths were rejected, so outsideFile should still exist
      expect(await outsideFile.exists(), isTrue);
    });
  });
}
