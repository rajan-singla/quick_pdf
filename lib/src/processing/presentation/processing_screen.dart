import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:quick_pdf/src/processing/presentation/processing_store.dart';

class ProcessingScreen extends StatefulWidget {
  final ProcessingStore store;
  final Function(String? path)? onComplete;

  const ProcessingScreen(this.store, {super.key, this.onComplete});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Processing PDF…")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Observer(
          builder: (_) {

            // Check if processing completed successfully
            if (!widget.store.isProcessing && widget.store.errorMessage == null && widget.store.progress == 1.0) {
              // Call completion callback
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onComplete?.call(widget.store.completedFilePath);
              });
            }

            if (widget.store.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      widget.store.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Go Back"),
                    ),
                  ],
                ),
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  strokeWidth: 6,
                ),
                const SizedBox(height: 32),
                Text(
                  widget.store.statusMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: LinearProgressIndicator(
                    value: widget.store.progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(12),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${(widget.store.progress * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
