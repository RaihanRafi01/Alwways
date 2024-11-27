/*
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
        'label': 'profile',
        'filledIcon': 'assets/images/home/profile_icon_filled.svg',
        'defaultIcon': 'assets/images/home/profile_icon.svg',
      },
    ];

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.green.shade800,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: onItemSelected,
      items: navItems.map((item) {
        final isSelected = navItems.indexOf(item) == selectedIndex;
        return BottomNavigationBarItem(
          icon: SvgPicture.asset(
            isSelected ? item['filledIcon']! : item['defaultIcon']!,
            key: ValueKey(isSelected), // Force rebuild
          ),
          label: item['label'],
        );
      }).toList(),
    );
  }
}
*/
