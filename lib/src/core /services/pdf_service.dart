import 'dart:isolate';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import 'pdf_events.dart';
import 'file_service.dart';

class PdfService {

  static Future<String> convertImagesInIsolate(
    List<XFile> images,
    void Function(PdfProgressEvent) onEvent,
  ) async {

    final receivePort = ReceivePort();
    
    // Get directory path in main isolate (platform channels available here)
    final dir = await getTemporaryDirectory();
    final outputDir = dir.path;

    await Isolate.spawn(
      _isolateEntry,
      _PdfIsolatePayload(
        images.map((e) => e.path).toList(),
        receivePort.sendPort,
        outputDir,
      ),
    );

    String outputPath = "";

    await for (final event in receivePort) {
      if (event is PdfProgressEvent) {
        onEvent(event);
      }

      if (event is String) {
        outputPath = event;
        break;
      }
    }

    print('Temporary PDF created at: $outputPath');
    print('Temp file exists: ${await File(outputPath).exists()}');

    // Save to permanent storage
    onEvent(PdfProgressEvent(1.0, "Saving to device…"));
    final permanentPath = await FileService.savePdfToPermanentStorage(outputPath);
    
    print('PDF saved permanently at: $permanentPath');
    print('Permanent file exists: ${await File(permanentPath).exists()}');

    return permanentPath;
  }

  /// --------- ISOLATE ENTRY ---------
  static Future<void> _isolateEntry(_PdfIsolatePayload payload) async {

    final sendPort = payload.port;
    final paths = payload.imagePaths;
    final outputDir = payload.outputDir;

    sendPort.send(PdfProgressEvent(0, "Preparing images…"));

    final pdf = pw.Document();

    for (int i = 0; i < paths.length; i++) {

      sendPort.send(PdfProgressEvent(
        (i / paths.length),
        "Adding page ${i + 1} of ${paths.length}…",
      ));

      final bytes = await File(paths[i]).readAsBytes();

      pdf.addPage(
        pw.Page(
          build: (_) => pw.Center(
            child: pw.Image(pw.MemoryImage(bytes)),
          ),
        ),
      );
    }

    sendPort.send(PdfProgressEvent(0.9, "Finalizing PDF…"));

    final output = "$outputDir/quickpdf_${DateTime.now().millisecondsSinceEpoch}.pdf";

    final file = File(output);
    await file.writeAsBytes(await pdf.save());

    sendPort.send(PdfProgressEvent(1.0, "Saving file…"));

    /// final message sent back to main isolate
    sendPort.send(output);
  }
}

class _PdfIsolatePayload {
  final List<String> imagePaths;
  final SendPort port;
  final String outputDir;

  _PdfIsolatePayload(this.imagePaths, this.port, this.outputDir);
}
