import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/color/app_colors.dart';

class SettingsList extends StatelessWidget {
  final String svgPath;
  final String text;
  final VoidCallback? onTap; // Optional callback for tap actions
  final bool isTogol; // Determines if a toggle switch is displayed
  final bool isToggled; // Current state of the toggle switch
  final Function(bool)? onToggleChanged; // Callback for toggle state changes

  const SettingsList({
    super.key,
    required this.svgPath,
    required this.text,
    this.onTap,
    this.isTogol = false,
    this.isToggled = false,
    this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: SvgPicture.asset(svgPath),
          title: Text(
            text,
            style: const TextStyle(fontSize: 18),
          ),
          trailing: isTogol
              ? Switch(
            activeColor: AppColors.appColor,
            inactiveThumbColor: AppColors.textColor,
            inactiveTrackColor: AppColors.textWhite,
            activeTrackColor: AppColors.onboardingText,
            value: isToggled, // Current toggle value
            onChanged: onToggleChanged, // Trigger toggle callback
          )
              : const Icon(Icons.navigate_next),
        ),
      ],
    );
  }
}
