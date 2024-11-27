import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImage extends StatelessWidget {
  final XFile? image;
  final VoidCallback onTap;

  const ProfileImage({
    super.key,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Profile Image Circle
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: image != null ? FileImage(File(image!.path)) : null,
            child: image == null
                ? const Icon(
              Icons.camera_alt,
              size: 30,
              color: Colors.white,
            )
                : null,
          ),
          // Camera Icon Button
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: CircleAvatar(radius: 12,
                  backgroundColor: Colors.white,
                  child: SvgPicture.asset('assets/images/camera_icon.svg'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
