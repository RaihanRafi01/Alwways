import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/controllers/chat/message_controller.dart';
import 'package:playground_02/controllers/chat/voice_controller.dart';

class MessageInput extends StatelessWidget {
  final MessageController _messageController = Get.find<MessageController>();
  final VoiceController _voiceController = Get.put(VoiceController());
  final TextEditingController _textController = TextEditingController();
  bool _isBottomSheetOpen = false;

  MessageInput({super.key});

  @override
  Widget build(BuildContext context) {
    _textController.addListener(() {
      _messageController.updateHasText(_textController.text);
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Message',
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 20.0),
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
                suffixIcon: IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/chat/att_icon.svg',
                  ),
                  onPressed: () {
                    // Handle attachment button press
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            return GestureDetector(
              onTap: () {
                if (_messageController.hasText.value) {
                  // Send text message
                  _messageController.sendMessage(_textController.text.trim());
                  _textController.clear();
                } else {
                  // Start listening for voice input
                  _voiceController.startListening();
                  _voiceController.isManuallyCancelled = false;
                  _showVoiceInputSheet(context);
                }
              },
              child: SvgPicture.asset(
                _messageController.hasText.value
                    ? 'assets/images/chat/send_icon.svg'
                    : 'assets/images/chat/mic_icon.svg',
                width: 36,
                height: 36,
              ),
            );
          }),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showMoreOptionsSheet(context),
            child: SvgPicture.asset("assets/images/chat/more_icon.svg",
              width: 36,
              height: 36,),
          )
        ],
      ),
    );
  }

  void _showMoreOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true, // Dismisses the modal when tapping outside
      isScrollControlled: true, // Custom size control
      backgroundColor: Colors.transparent, // Transparent for custom width
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context), // Close on tapping outside
          child: Container(
            color: Colors.transparent, // Transparent to detect outside taps
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60.0,right: 10),
                child: Container(
                  width: 150, // Fixed width
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: AppColors.appColor, // Add your border color here
                      width: 2.0, // Border thickness
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.appColor,
                        blurRadius: 5.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Option 1'),
                        onTap: () {
                          // Handle Option 1
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('Option 2'),
                        onTap: () {
                          // Handle Option 2
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('Option 2'),
                        onTap: () {
                          // Handle Option 2
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('Option 2'),
                        onTap: () {
                          // Handle Option 2
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('Option 2'),
                        onTap: () {
                          // Handle Option 2
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
                    Obx(() {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          _voiceController.recognizedText.value,
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }),
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
                    _voiceController.isManuallyCancelled = true;
                    _voiceController.cancelVoiceInput();
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
      if (!_voiceController.isManuallyCancelled &&
          _voiceController.recognizedText.isNotEmpty) {
        _voiceController.sendRecognizedText();
      }
    });
    // Listen for recognized text to close the sheet
    _voiceController.recognizedText.listen((text) {
      if (text.isNotEmpty && _isBottomSheetOpen) {
        Navigator.pop(context);
        _isBottomSheetOpen = false;
        if (!_voiceController.isManuallyCancelled) {
          _voiceController.sendRecognizedText();
        }
      }
    });
  }
}
