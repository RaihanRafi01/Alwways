import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/auth_controller.dart';
import 'package:playground_02/views/authentication/signup_screen.dart';
import 'package:playground_02/widgets/customAppBar.dart';
import 'package:playground_02/widgets/authentication/profileImage.dart';

class ProfileScreen extends StatelessWidget {
   ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    return GetBuilder<AuthController>(
      init: Get.find<AuthController>(),
      initState: (_) => Get.find<AuthController>().fetchProfile(),
      builder: (controller) {
        return Scaffold(
          appBar: const CustomAppbar(title: 'Profile', isHome: true),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Obx(
                            () => ProfileImage(
                              isEdit: true,
                          pickedImage: controller.pickedImage.value,
                          profilePictureUrl: controller.profilePictureUrl.value,
                          onTap: controller.pickImage,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(
                            () => Text(
                          controller.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading:
                  SvgPicture.asset("assets/images/profile/profile_edit_icon.svg"),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.to(() => const SignupScreen(isEdit: true, title: 'Edit Profile'));
                  },
                ),
                Obx(
                      () => ProfileItem(
                    svgPath: "assets/images/profile/email_icon.svg",
                    title: controller.email.value,
                  ),
                ),
                Obx(
                      () => ProfileItem(
                    svgPath: "assets/images/profile/phone_icon.svg",
                    title: controller.contact.value,
                  ),
                ),
                Obx(
                      () => ProfileItem(
                    svgPath: "assets/images/profile/gender_icon.svg",
                    title: controller.gender.value,
                  ),
                ),
                Obx(
                      () => ProfileItem(
                    svgPath: "assets/images/profile/dob_icon.svg",
                    title: controller.formattedDateOfBirth,
                  ),
                ),
                Obx(
                      () => ProfileItem(
                    svgPath: "assets/images/profile/location_icon.svg",
                    title: controller.location.value,
                  ),
                ),
                ListTile(
                  leading: SvgPicture.asset("assets/images/profile/log_out_icon.svg"),
                  title: const Text('Log Out'),
                  onTap: controller.logout,
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProfileItem extends StatelessWidget {
  final String svgPath;
  final String title;

  const ProfileItem({Key? key, required this.svgPath, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(svgPath),
      title: Text(title),
    );
  }
}