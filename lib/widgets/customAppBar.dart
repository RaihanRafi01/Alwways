import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/chat/prompt_bottomSheet.dart';

import '../constants/color/app_colors.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final bool isHome;
  final bool showIcon;
  final bool isEdit;
  final String title;
  final bool isback;
  final Color bgColor;

  const CustomAppbar({
    super.key,
    this.isHome = false,
    this.isEdit = false,
    this.isback = false,
    this.bgColor = Colors.transparent,
    this.showIcon = true, // Default to true
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      backgroundColor: bgColor,
      leading: isback? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Get.back();
        },
      ) : null,
      title: Text(
        title,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: showIcon
          ? isEdit
          ? [
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SvgPicture.asset(
              "assets/images/book/lock_icon.svg",
              height: 20,
              width: 20,
            ),
          ),
          onTap: () {
            _showLockPopup(context, 'Lock Chapter', 'If you turn on the lock the AI  will not make any further changes to the  with any new chat.');
          },
        ),
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SvgPicture.asset(
              "assets/images/book/delete_icon.svg",
              height: 20,
              width: 20,
            ),
          ),
          onTap: () {
            _showDeletePopup(context, 'Delete', 'Do you want to delete this chapter');
          },
        ),
      ]
          : [
        /*GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: isHome
                ? SvgPicture.asset(
              "assets/images/home/home_appbar_icon.svg",
              height: 30,
              width: 30,
            )
                : SvgPicture.asset("assets/images/chat/prompt_icon.svg"),
          ),
          onTap: () {
            if (isHome) {
              print("Home icon tapped! Add your functionality here.");
            } else {
              showModalBottomSheet(
                context: context,
                builder: (_) => const PromptBottomSheet(),
              );
            }
          },
        ),*/
      ]
          : [], // No icon shown if showIcon is false
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showDeletePopup(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center, // Centering the title text
          ),
          content: Text(
            content,
            textAlign: TextAlign.center, // Centering the content text
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CustomButton(
                isEditPage: true,
                text: "delete",
                onPressed: () {},
                backgroundColor: AppColors.buttonRed,
                borderColor: AppColors.buttonRed,
              ),
            ),
            CustomButton(
              isEditPage: true,
              text: "cancel",
              onPressed: () => Get.back(),
              backgroundColor: Colors.transparent,
              textColor: AppColors.appColor,
            ),
          ],
        );
      },
    );
  }

  void _showLockPopup(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center, // Centering the title text
          ),
          content: Text(
            content,
            textAlign: TextAlign.center, // Centering the content text
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CustomButton(
                height: 60,
                isEditPage: true,
                text: "Yes, turn on lock mode",
                onPressed: () {},
                backgroundColor: AppColors.appColor,
              ),
            ),
            CustomButton(
              height: 60,
              isEditPage: true,
              text: "No, save using lock off",
              onPressed: () => Get.back(),
              backgroundColor: Colors.transparent,
              textColor: AppColors.appColor,
            ),
          ],
        );
      },
    );
  }
}
