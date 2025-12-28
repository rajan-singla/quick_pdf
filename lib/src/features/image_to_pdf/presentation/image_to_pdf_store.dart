import 'package:mobx/mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_pdf/src/core%20/services/pdf_service.dart';
import 'package:quick_pdf/src/processing/presentation/processing_store.dart';

part 'image_to_pdf_store.g.dart';

class ImageToPdfStore = _ImageToPdfStore with _$ImageToPdfStore;

abstract class _ImageToPdfStore with Store {

  final ProcessingStore processingStore = ProcessingStore();


  /// observable list of images
  @observable
  ObservableList<XFile> images = ObservableList<XFile>();

  /// whether UI should enable convert button
  @computed
  bool get hasImages => images.isNotEmpty;

  /// ---- ACTIONS ----

  @action
  Future<void> pickImages(ImagePicker picker) async {
    final selected = await picker.pickMultiImage();
    if (selected.isEmpty) return;
    images.addAll(selected);
  }

  @action
  void removeImage(int index) {
    images.removeAt(index);
  }

  @action
  void clear() {
    images.clear();
  }

  @action
Future<String?> convertToPdf() async {

  if (images.isEmpty) return null;

  processingStore.start();

  try {
    final path = await PdfService.convertImagesInIsolate(
      images,
      (event) {
        processingStore.updateProgress(event.progress);
        processingStore.updateMessage(event.message);
      },
    );

    processingStore.complete(filePath: path);
    return path;

  } catch (e) {
    processingStore.fail(e.toString());
    return null;
  }
}

}
