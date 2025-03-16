import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/chat/message_controller.dart';
import 'package:playground_02/controllers/chat/voice_controller.dart';
// Assuming you have an AppColors file
import 'package:playground_02/constants/color/app_colors.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final MessageController messageController = Get.find<MessageController>();
  final VoiceController voiceController = Get.put(VoiceController());
  bool _isBottomSheetOpen = false;

  MessageInput({super.key});

  @override
  Widget build(BuildContext context) {
    _controller.addListener(() {
      messageController.updateHasText(_controller.text);
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Message',
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 20.0,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                    color: AppColors.borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                    color: AppColors.borderColor,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => GestureDetector(
            onTap: () {
              if (messageController.hasText.value) {
                messageController.sendMessage(_controller.text.trim());
                _controller.clear();
              } else {
                voiceController.startListening();
                voiceController.isManuallyCancelled = false;
                _showVoiceInputSheet(context);
              }
            },
            child: SvgPicture.asset(
              messageController.hasText.value
                  ? 'assets/images/chat/send_icon.svg'
                  : 'assets/images/chat/mic_icon.svg',
              width: 36,
              height: 36,
            ),
          )),
        ],
      ),
    );
  }

  void _showVoiceInputSheet(BuildContext context) {
    if (_isBottomSheetOpen) return;
    _isBottomSheetOpen = true;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/chat/listening_icon.svg',
                      height: 22,
                      width: 77,
                    ),
                    const SizedBox(height: 20),
                    Obx(() => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        voiceController.recognizedText.value,
                        style: TextStyle(fontSize: 16),
                      ),
                    )),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: SvgPicture.asset(
                  'assets/images/chat/att_icon.svg',
                  height: 32,
                  width: 32,
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    voiceController.isManuallyCancelled = true;
                    voiceController.cancelVoiceInput();
                    if (_isBottomSheetOpen) {
                      Navigator.pop(context);
                      _isBottomSheetOpen = false;
                    }
                  },
                  child: SvgPicture.asset(
                    'assets/images/chat/cancel_icon.svg',
                    height: 32,
                    width: 32,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      _isBottomSheetOpen = false;
      if (!voiceController.isManuallyCancelled &&
          voiceController.recognizedText.isNotEmpty) {
        voiceController.sendRecognizedText();
      }
    });

    voiceController.recognizedText.listen((text) {
      if (text.isNotEmpty && _isBottomSheetOpen) {
        Navigator.pop(context);
        _isBottomSheetOpen = false;
        if (!voiceController.isManuallyCancelled) {
          voiceController.sendRecognizedText();
        }
      }
    });
  }
}