import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinCodeInputField extends StatelessWidget {
  final int length;
  final void Function(String) onCompleted;

  const PinCodeInputField({
    super.key,
    this.length = 4,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: PinCodeTextField(
        appContext: context,
        length: length,
        animationType: AnimationType.scale,
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(8),
          fieldHeight: 50,
          fieldWidth: 50,
          activeFillColor: Colors.grey[200],
          selectedFillColor: Colors.grey[200],
          inactiveFillColor: Colors.grey[200],
          activeColor: Colors.grey[400]!,
          selectedColor: Colors.blue,
          inactiveColor: Colors.grey[400]!,
        ),
        cursorColor: Colors.black,
        keyboardType: TextInputType.number,
        enableActiveFill: true,
        onChanged: (value) {
          // Optional: Handle changes if needed
        },
        onCompleted: onCompleted,  // Calls onCompleted callback with the PIN
      ),
    );
  }
}
