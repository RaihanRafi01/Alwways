import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/widgets/chat/prompt_bottomSheet.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final bool isHome;
  final bool showIcon;
  final String title;

  const CustomAppbar({
    super.key,
    this.isHome = false,
    this.showIcon = true, // Default to true
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Get.back();
        },
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: showIcon
          ? [
        GestureDetector(
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
        ),
      ]
          : [], // No icon shown if showIcon is false
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
