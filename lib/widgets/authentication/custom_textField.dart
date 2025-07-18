import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:playground_02/constants/color/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final bool isPassword;
  final bool readOnly;
  final bool phone;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final Function()? onTap;
  final String? initialValue;
  final bool isDropdown;
  final List<String>? dropdownItems;
  final double radius;
  final Color textColor;
  final String hint;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint = '',
    this.isPassword = false,
    this.readOnly = false,
    this.phone = false,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.keyboardType,
    this.onTap,
    this.initialValue,
    this.isDropdown = false,
    this.dropdownItems,
    this.radius = 10,
    this.textColor = Colors.black,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    if (!widget.isPassword) {
      _obscureText = false;
    }
    if (!widget.phone && widget.initialValue != null && widget.controller != null) {
      widget.controller!.text = widget.initialValue!;
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.textColor,
          ),
        ),
        const SizedBox(height: 8),
        widget.isDropdown
            ? DropdownButtonFormField<String>(
          value: widget.initialValue != null &&
              widget.dropdownItems?.contains(widget.initialValue) == true
              ? widget.initialValue
              : (widget.dropdownItems?.isNotEmpty == true
              ? widget.dropdownItems!.first
              : null),
          items: widget.dropdownItems
              ?.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          ))
              .toList(),
          onChanged: (value) {
            if (value != null && widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius),
              borderSide: const BorderSide(color: AppColors.borderColor, width: 2),
            ),
          ),
        )
            : widget.phone
            ? IntlPhoneField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius),
              borderSide: const BorderSide(color: AppColors.borderColor, width: 2),
            ),
          ),
          initialCountryCode: 'BD', // Default to Bangladesh
          initialValue: widget.initialValue, // Use initialValue for pre-filling
          onChanged: (phone) {
            if (widget.onChanged != null) {
              widget.onChanged!(phone.completeNumber);
            }
            // Update the controller if provided
            if (widget.controller != null) {
              widget.controller!.text = phone.completeNumber;
            }
          },
        )
            : TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: widget.isPassword ? _obscureText : false,
          readOnly: widget.readOnly,
          keyboardType: widget.keyboardType,
          onTap: widget.onTap,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: _togglePasswordVisibility,
            )
                : (widget.suffixIcon != null ? Icon(widget.suffixIcon) : null),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius),
              borderSide: const BorderSide(color: AppColors.borderColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}