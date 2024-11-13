import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'message_controller.dart';

class VoiceController extends GetxController {
  final RxString recognizedText = ''.obs;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final RxBool isListening = false.obs;
  bool isManuallyCancelled = false; // Track manual cancellation

  Future<void> startListening() async {
    isManuallyCancelled = false; // Reset on new listening session
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          // Stop listening when done
          stopListening();
          if (!isManuallyCancelled) {
            sendRecognizedText(); // Send only if not manually canceled
          }
        }
      },
      onError: (error) => print('Error: $error'),
    );

    if (available) {
      isListening.value = true;
      _speech.listen(
        onResult: (result) {
          recognizedText.value = result.recognizedWords;
        },
      );
    }
  }

  void stopListening() {
    _speech.stop();
    isListening.value = false;
  }

  void cancelVoiceInput() {
    isManuallyCancelled = true; // Mark as manually cancelled
    stopListening();
    recognizedText.value = ''; // Clear recognized text on cancel
  }

  void sendRecognizedText() {
    if (recognizedText.value.isNotEmpty) {
      final MessageController messageController = Get.find<MessageController>();
      messageController.sendMessage(recognizedText.value.trim());
      recognizedText.value = ''; // Clear the recognized text after sending
    }
  }
}
