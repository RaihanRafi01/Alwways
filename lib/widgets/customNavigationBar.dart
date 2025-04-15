import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../constants/color/app_colors.dart';
import '../views/dashboard/controllers/dashboard_controller.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    final List<Map<String, String>> navItems = [
      {
        'label': 'Home',
        'filledIcon': 'assets/images/home/home_icon_filled.svg',
        'defaultIcon': 'assets/images/home/home_icon.svg',
      },
      {
        'label': 'Book',
        'filledIcon': 'assets/images/home/book_icon_filled.svg',
        'defaultIcon': 'assets/images/home/book_icon.svg',
      },
      {
        'label': 'Profile',
        'filledIcon': 'assets/images/home/profile_icon_filled.svg',
        'defaultIcon': 'assets/images/home/profile_icon.svg',
      },
    ];

    return Container(
      height: 60,
      color: AppColors.appBackground,
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final isSelected = index == controller.currentIndex.value;
          final item = navItems[index];
          return GestureDetector(
            onTap: () {
              print("Tapped on ${item['label']}"); // Debugging
              controller.updateIndex(index);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                isSelected ? item['filledIcon']! : item['defaultIcon']!,
              ),
            ),
          );
        }),
      )),
    );
  }
}
