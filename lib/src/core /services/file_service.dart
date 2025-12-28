import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileService {
  /// Save PDF using scoped storage (Android) or app documents (iOS)
  /// This approach is compliant with Google Play Store policies
  static Future<String> savePdfToPermanentStorage(String tempFilePath) async {
    final file = File(tempFilePath);
    
    if (!await file.exists()) {
      throw Exception('Temporary file does not exist');
    }

    Directory directory;
    
    if (Platform.isAndroid) {
      // For Android: Use app-specific directory (scoped storage compliant)
      // This doesn't require special permissions and is accepted by Play Store
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      // For iOS: Use application documents directory
      directory = await getApplicationDocumentsDirectory();
    } else {
      // For desktop platforms
      directory = await getApplicationDocumentsDirectory();
    }

    // Create QuickPDF subdirectory
    final quickPdfDir = Directory(path.join(directory.path, 'QuickPDF'));
    if (!await quickPdfDir.exists()) {
      await quickPdfDir.create(recursive: true);
    }

    // Generate filename with timestamp
    final fileName = 'QuickPDF_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final permanentPath = path.join(quickPdfDir.path, fileName);

    // Copy file to permanent location
    await file.copy(permanentPath);

    // Delete temporary file
    try {
      await file.delete();
    } catch (e) {
      // Ignore deletion errors for temp files
    }

    return permanentPath;
  }

  /// Get file size in bytes
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return await file.length();
  }

  /// Check if file exists
  static Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  /// Delete file
  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
