import 'dart:async';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'message_controller.dart';

class VoiceController extends GetxController {
  final RxString recognizedText = ''.obs; // Live display during speaking
  final stt.SpeechToText _speech = stt.SpeechToText();
  final RxBool isListening = false.obs;
  bool isManuallyCancelled = false;
  Timer? _pauseTimer;
  bool _hasSentFinalText = false; // Flag to prevent repeated sends

  Future<void> startListening() async {
    isManuallyCancelled = false;
    _hasSentFinalText = false; // Reset flag at the start of listening

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          stopListening();
          if (!isManuallyCancelled && !_hasSentFinalText) {
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
          _handleSpeechResult(result.recognizedWords);
        },
      );
    }
  }

  void _handleSpeechResult(String words) {
    _pauseTimer?.cancel(); // Reset the timer on new input
    recognizedText.value = words; // Show interim result during speaking
    _hasSentFinalText = false; // Reset flag when new speech is detected

    // Start a 6-second timer to finalize text if the user pauses
    _pauseTimer = Timer(Duration(seconds: 6), () {
      if (!_hasSentFinalText && recognizedText.value.isNotEmpty) {
        sendRecognizedText(); // Send the final text after pause
        _hasSentFinalText = true; // Set flag to prevent repeated sends
      }
    });
  }

  void stopListening() {
    _speech.stop();
    isListening.value = false;
    _pauseTimer?.cancel(); // Cancel the timer when stopped
  }

  void cancelVoiceInput() {
    isManuallyCancelled = true;
    stopListening();
    recognizedText.value = ''; // Clear recognized text on cancel
  }

  void sendRecognizedText() {
    if (recognizedText.value.isNotEmpty) {
      final MessageController messageController = Get.find<MessageController>();
      messageController.sendMessage(recognizedText.value.trim());
      recognizedText.value = ''; // Clear recognized text after sending
      _pauseTimer?.cancel(); // Ensure the timer is canceled after sending
    }
  }
}
