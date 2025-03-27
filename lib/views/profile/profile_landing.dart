import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/auth_controller.dart';
import 'package:playground_02/views/authentication/signup_screen.dart';
import 'package:playground_02/widgets/customAppBar.dart';
import 'package:playground_02/widgets/authentication/profileImage.dart';

import '../setting/views/setting_view.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure AuthController is available
    Get.put(AuthController()); // This initializes the controller if not already done
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppbar(title: "profile".tr, isHome: true),
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
                  leading: SvgPicture.asset("assets/images/profile/profile_edit_icon.svg"),
                  title: Text("edit_profile".tr),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Get.to(() => SignupScreen(isEdit: true, title: "edit_profile".tr));
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
                GestureDetector(
                  onTap: (){
                    Get.to(()=> const SettingView());
                  },
                  child: ProfileItem(
                    svgPath: "assets/images/profile/setting_icon.svg",
                    title: "settings".tr,
                  ),
                ),
                ListTile(
                  leading: SvgPicture.asset("assets/images/profile/log_out_icon.svg"),
                  title: Text("log_out".tr),
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

  const ProfileItem({Key? key, required this.svgPath, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(svgPath),
      title: Text(title),
    );
  }
}