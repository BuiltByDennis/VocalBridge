import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:kasa_me/storage/database/app_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class DataDeletionService {
  final AppDatabase database;

  DataDeletionService({
    required this.database,
  });

  Future<void> deleteAllLocalData() async {
    // Clear database tables securely
    await database.delete(database.personalVocabulary).go();
    await database.delete(database.personalPhrases).go();
    await database.delete(database.recognitionEvents).go();
    await database.delete(database.speechCorrections).go();
    await database.delete(database.wordCorrections).go();
    await database.delete(database.phraseCorrections).go();
    await database.delete(database.phrasebookEntries).go();
    
    // Clear FlutterSecureStorage
    const secureStorage = FlutterSecureStorage();
    await secureStorage.deleteAll();

    // Securely clear Application Documents Directory
    final docsDir = await getApplicationDocumentsDirectory();
    await _safeDeleteDirectory(docsDir);

    // Securely clear Temporary Directory
    final tempDir = await getTemporaryDirectory();
    await _safeDeleteDirectory(tempDir);

    debugPrint('[DataDeletionService] Finished destructive delete.');
  }

  /// Recursively deletes a directory safely, enforcing boundaries.
  Future<void> _safeDeleteDirectory(Directory dir) async {
    try {
      final String resolvedPath = dir.resolveSymbolicLinksSync();
      
      if (!_isSafeDeletionTarget(resolvedPath)) {
        debugPrint('[DataDeletionService] ERROR: Unsafe deletion target rejected: $resolvedPath');
        return;
      }

      if (await dir.exists()) {
        await for (var entity in dir.list(recursive: false)) {
          final entityPath = entity.resolveSymbolicLinksSync();
          if (_isSafeDeletionTarget(entityPath)) {
             await entity.delete(recursive: true);
          } else {
             debugPrint('[DataDeletionService] ERROR: Unsafe nested target rejected: $entityPath');
          }
        }
      }
    } catch (e) {
      debugPrint('[DataDeletionService] ERROR clearing directory: $e');
    }
  }

  /// Verifies if a path is safe to delete.
  bool _isSafeDeletionTarget(String path) {
    if (path.isEmpty) return false;
    if (path == '.') return false;
    if (path == '..') return false;
    if (path == '/') return false;
    
    // Canonicalize path
    final canonicalPath = p.canonicalize(path);
    
    if (canonicalPath == '/') return false;
    
    // Protection against deleting project root (if mistakenly passed)
    if (canonicalPath.endsWith('kasa_me') || canonicalPath.endsWith('VocalBridge')) return false;

    // Reject obvious traversal
    if (canonicalPath.contains('..')) return false;
    
    return true;
  }
}
