import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.green.shade800,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: onItemSelected,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            selectedIndex == 0
                ? "assets/images/home/home_icon_filled.svg" // Filled icon when selected
                : "assets/images/home/home_icon.svg", // Default icon when unselected
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            selectedIndex == 1
                ? "assets/images/home/book_icon.svg" // Filled icon when selected
                : "assets/images/home/book_icon.svg", // Default icon when unselected
          ),
          label: 'Book',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            selectedIndex == 2
                ? "assets/images/home/qna_icon_filled.svg" // Filled icon when selected
                : "assets/images/home/qna_icon.svg", // Default icon when unselected
          ),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            selectedIndex == 3
                ? "assets/images/home/setting_icon_filled.svg" // Filled icon when selected
                : "assets/images/home/setting_icon.svg", // Default icon when unselected
          ),
          label: 'Settings',
        ),
      ],
    );
  }
}
