import 'package:mobx/mobx.dart';

part 'processing_store.g.dart';

class ProcessingStore = _ProcessingStore with _$ProcessingStore;

abstract class _ProcessingStore with Store {

  @observable
  double progress = 0;

  @observable
  bool isProcessing = false;

  @observable
  String? errorMessage;

  @observable
  String statusMessage = "Preparing…";
  
  @observable
  String? completedFilePath;

  @action
  void start() {
    isProcessing = true;
    progress = 0;
    statusMessage = "Preparing images…";
    errorMessage = null;
    completedFilePath = null;
  }

  @action
  void updateProgress(double value) {
    progress = value;
  }

  @action
  void updateMessage(String message) {
    statusMessage = message;
  }

  @action
  void fail(String message) {
    isProcessing = false;
    errorMessage = message;
  }

  @action
  void complete({String? filePath}) {
    isProcessing = false;
    progress = 1.0;
    statusMessage = "Completed";
    completedFilePath = filePath;
  }
}
