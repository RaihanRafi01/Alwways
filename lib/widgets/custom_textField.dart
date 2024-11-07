import 'package:flutter/material.dart';
import 'package:playground_02/constants/color/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool isPassword;
  final bool readOnly;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final Function()? onTap;
  final String? initialValue;
  final bool isDropdown;
  final List<String>? dropdownItems;

  const CustomTextField({
    Key? key,
    required this.label,
    this.isPassword = false,
    this.readOnly = false,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.keyboardType,
    this.onTap,
    this.initialValue,
    this.isDropdown = false,
    this.dropdownItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        isDropdown
            ? DropdownButtonFormField<String>(
          value: dropdownItems?.isNotEmpty == true ? dropdownItems!.first : null,
          items: dropdownItems
              ?.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged!(value);
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderColor), // Default color
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderColor, width: 2), // Color when focused
            ),
          ),
        )
            :
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: isPassword,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onTap: onTap,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.borderColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
