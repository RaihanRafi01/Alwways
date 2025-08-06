import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/controllers/auth_controller.dart';
import 'package:playground_02/views/authentication/signup_screen.dart';
import 'package:playground_02/widgets/customAppBar.dart';
import 'package:playground_02/widgets/authentication/profileImage.dart';

import '../../constants/color/app_colors.dart';
import '../setting/controllers/setting_controller.dart';
import '../setting/views/setting_view.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are available
    Get.put(AuthController()); // Initialize AuthController if not already done
    Get.put(SettingController()); // Initialize SettingController if not already done

    return GetBuilder<AuthController>(
      builder: (authController) {
        return GetBuilder<SettingController>(
          builder: (settingController) {
            // Helper method to map gender based on language
            String getDisplayedGender(String gender) {
              if (settingController.selectedLanguage.value == 'Spanish') {
                switch (gender) {
                  case 'Male':
                    return 'Masculino';
                  case 'Female':
                    return 'Femenino';
                  case 'Other':
                    return 'Otro';
                  default:
                    return gender; // Fallback to original value
                }
              }
              return gender; // Return English value if language is not Spanish
            }

            return Scaffold(
              backgroundColor: AppColors.appBackground,
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
                              pickedImage: authController.pickedImage.value,
                              profilePictureUrl: authController.profilePictureUrl.value,
                              onTap: authController.pickImage,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Obx(
                                () => Text(
                              authController.fullName,
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
                        title: authController.email.value,
                      ),
                    ),
                    Obx(
                          () => ProfileItem(
                        svgPath: "assets/images/profile/phone_icon.svg",
                        title: authController.contact.value,
                      ),
                    ),
                    Obx(
                          () => ProfileItem(
                        svgPath: "assets/images/profile/gender_icon.svg",
                        title: getDisplayedGender(authController.gender.value),
                      ),
                    ),
                    Obx(
                          () => ProfileItem(
                        svgPath: "assets/images/profile/dob_icon.svg",
                        title: authController.formattedDateOfBirth,
                      ),
                    ),
                    Obx(
                          () => ProfileItem(
                        svgPath: "assets/images/profile/location_icon.svg",
                        title: authController.location.value,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const SettingView());
                      },
                      child: ProfileItem(
                        svgPath: "assets/images/profile/setting_icon.svg",
                        title: "settings".tr,
                      ),
                    ),
                    ListTile(
                      leading: SvgPicture.asset("assets/images/profile/log_out_icon.svg"),
                      title: Text("log_out".tr),
                      onTap: authController.logout,
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            );
          },
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