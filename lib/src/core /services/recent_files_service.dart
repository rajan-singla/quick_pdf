import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class RecentFile {
  final String name;
  final String path;
  final int sizeInBytes;
  final DateTime createdAt;

  RecentFile({
    required this.name,
    required this.path,
    required this.sizeInBytes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'path': path,
        'sizeInBytes': sizeInBytes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RecentFile.fromJson(Map<String, dynamic> json) => RecentFile(
        name: json['name'] as String,
        path: json['path'] as String,
        sizeInBytes: json['sizeInBytes'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class RecentFilesService {
  static const String _fileName = 'recent_files.json';
  static const int _maxRecentFiles = 10;

  /// Get the file where recent files list is stored
  static Future<File> _getStorageFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(path.join(directory.path, _fileName));
  }

  /// Add a new file to recent files
  static Future<void> addRecentFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return;

      final recentFile = RecentFile(
        name: path.basename(filePath),
        path: filePath,
        sizeInBytes: await file.length(),
        createdAt: DateTime.now(),
      );

      final recentFiles = await getRecentFiles();

      // Remove if already exists (to update it to top)
      recentFiles.removeWhere((f) => f.path == filePath);

      // Add to beginning
      recentFiles.insert(0, recentFile);

      // Keep only the most recent files
      if (recentFiles.length > _maxRecentFiles) {
        recentFiles.removeRange(_maxRecentFiles, recentFiles.length);
      }

      await _saveRecentFiles(recentFiles);
    } catch (e) {
      print('Error adding recent file: $e');
    }
  }

  /// Get list of recent files
  static Future<List<RecentFile>> getRecentFiles() async {
    try {
      final file = await _getStorageFile();
      if (!await file.exists()) return [];

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);

      final recentFiles = jsonList
          .map((json) => RecentFile.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filter out files that no longer exist
      final existingFiles = <RecentFile>[];
      for (final recentFile in recentFiles) {
        if (await File(recentFile.path).exists()) {
          existingFiles.add(recentFile);
        }
      }

      // Update storage if files were removed
      if (existingFiles.length != recentFiles.length) {
        await _saveRecentFiles(existingFiles);
      }

      return existingFiles;
    } catch (e) {
      print('Error loading recent files: $e');
      return [];
    }
  }

  /// Save recent files list
  static Future<void> _saveRecentFiles(List<RecentFile> files) async {
    try {
      final file = await _getStorageFile();
      final jsonList = files.map((f) => f.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error saving recent files: $e');
    }
  }

  /// Clear all recent files
  static Future<void> clearRecentFiles() async {
    try {
      final file = await _getStorageFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing recent files: $e');
    }
  }

  /// Remove a specific file from recent files
  static Future<void> removeRecentFile(String filePath) async {
    try {
      final recentFiles = await getRecentFiles();
      recentFiles.removeWhere((f) => f.path == filePath);
      await _saveRecentFiles(recentFiles);
    } catch (e) {
      print('Error removing recent file: $e');
    }
  }
}
