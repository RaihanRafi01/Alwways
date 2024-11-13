import 'package:flutter/material.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:get/get.dart';  // Import GetX package

class LanguageOptionTile extends StatelessWidget {
  final String imagePath;
  final String languageName;
  final String languageCode;
  final String selectedLanguage;
  final ValueChanged<String> onChanged;

  const LanguageOptionTile({
    super.key,
    required this.imagePath,
    required this.languageName,
    required this.languageCode,
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderColor,
        ),
        color: selectedLanguage == languageCode
            ? AppColors.buttonBorderColor.withOpacity(.4)
            : AppColors.buttonBorderColorInactive, // Use inactive color here
      ),
      child: ListTile(
        leading: Image.asset(imagePath, width: 30),
        title: Text(languageName),
        trailing: selectedLanguage == languageCode
            ? const Icon(Icons.check_box_rounded, color: AppColors.buttonBorderColor)
            : null,
        onTap: () {
          // Update the language by calling the onChanged callback
          onChanged(languageCode);
        },
      ),
    );
  }
}
