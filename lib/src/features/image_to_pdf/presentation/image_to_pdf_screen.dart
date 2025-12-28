import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_pdf/src/features/image_to_pdf/presentation/image_to_pdf_store.dart';
import 'package:quick_pdf/src/processing/presentation/processing_screen.dart';
import 'package:quick_pdf/src/features/result/presentation/result_screen.dart';

class ImageToPdfScreen extends StatelessWidget {
  const ImageToPdfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ImageToPdfStore();

    return Scaffold(
      appBar: AppBar(title: const Text("Image → PDF")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select images and arrange order",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),

            const SizedBox(height: 16),

            /// observe thumbnails
            Expanded(
              child: Observer(
                builder: (_) {
                  return GridView.builder(
                    itemCount: store.images.length + 1,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _addImageTile(
                          () => store.pickImages(ImagePicker()),
                        );
                      }

                      final image = store.images[index - 1];

                      return _imageTile(
                        image: image,
                        onDelete: () => store.removeImage(index - 1),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _optionCard("Page Size", "A4")),
                const SizedBox(width: 10),
                Expanded(child: _optionCard("Orientation", "Auto")),
              ],
            ),

            const SizedBox(height: 16),

            /// observe button enable state
            Observer(
              builder: (_) {
                return ElevatedButton(
                  onPressed: store.hasImages
                      ? () async {
                          // Navigate to Processing Screen immediately
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProcessingScreen(
                                store.processingStore,
                                onComplete: (path) async {
                                  // When processing completes, navigate to result
                                  if (path != null) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ResultScreen(
                                          filePath: path,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );

                          // Start conversion in background
                          await store.convertToPdf();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Convert to PDF"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _addImageTile(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: const Center(child: Icon(Icons.add, size: 30)),
      ),
    );
  }

  Widget _imageTile({required XFile image, required VoidCallback onDelete}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: FileImage(File(image.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),

        Positioned(
          right: 6,
          top: 6,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _optionCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
