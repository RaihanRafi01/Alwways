import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../constants/color/app_colors.dart';
import '../authentication/custom_button.dart';

class CustomDeletePopup extends StatefulWidget {
  final VoidCallback onButtonPressed1;
  final VoidCallback onButtonPressed2;
  final String title;

  const CustomDeletePopup({
    super.key,
    required this.onButtonPressed1,
    required this.onButtonPressed2,
    this.title = 'Do you want to delete this File '
  });

  @override
  _CustomDeletePopupState createState() => _CustomDeletePopupState();
}

class _CustomDeletePopupState extends State<CustomDeletePopup> {
  // Controllers for the text fields

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: EdgeInsets.zero,
      content: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 32, left: 16, right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Popup text
                Text('delete'.tr, style: TextStyle(
                    fontSize: 20,
                    color: Colors.redAccent),
                ),
                SizedBox(height: 26),
                Text(widget.title, style: TextStyle(
                    fontSize: 14,
                    color: AppColors.appColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 26),

                // Button to trigger action
                CustomButton(text: 'delete'.tr, onPressed: widget.onButtonPressed1,backgroundColor: Colors.red,),
                SizedBox(height: 16),
                CustomButton(text: 'cancel'.tr, onPressed: widget.onButtonPressed2,backgroundColor: Colors.white,isEditPage: true,textColor: AppColors.appColor,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
