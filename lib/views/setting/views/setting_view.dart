import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/views/authentication/login_screen.dart';
import 'package:playground_02/views/subscription/cupon_view.dart';
import '../../../constants/color/app_colors.dart';
import '../../../constants/translations/language_controller.dart';
import '../../../widgets/settings/customDeletePopUp.dart';
import '../../../widgets/settings/settingsList.dart';
import '../../subscription/subscription_view.dart';
import '../controllers/setting_controller.dart';
import 'help_support_view.dart';
import 'terms_privacy_view.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize both controllers
    Get.put(SettingController());

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        title: Text("settings".tr, style: const TextStyle(fontSize: 26)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Section
              Text("account".tr, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              SettingsList(
                svgPath: 'assets/images/settings/subscription_icon.svg',
                text: "manage_subscription".tr,
                onTap: () => Get.to(() => const SubscriptionView()),
              ),
              SettingsList(
                svgPath: 'assets/images/settings/delete_icon.svg',
                text: "delete_account".tr,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return CustomDeletePopup(
                        title: "delete_account_confirmation".tr,
                        onButtonPressed1: () {
                          // Delete logic
                        },
                        onButtonPressed2: () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
              ),
              SettingsList(
                svgPath: 'assets/images/settings/terms_icon.svg',
                text: "terms_and_condition".tr,
                onTap: () => Get.to(() => const TermsPrivacyView(isTerms: true)),
              ),
              SettingsList(
                svgPath: 'assets/images/settings/privacy_icon.svg',
                text: "privacy_policy".tr,
                onTap: () => Get.to(() => const TermsPrivacyView(isTerms: false)),
              ),
          
              // Help Section
              Text("help".tr, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              SettingsList(
                svgPath: 'assets/images/settings/email_icon.svg',
                text: "email_support".tr,
                onTap: () => Get.to(() => HelpSupportView()),
              ),
          
              // Notification Section with Toggle
              Text("notification".tr, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Obx(() {
                return SettingsList(
                  svgPath: 'assets/images/settings/notification_icon.svg',
                  text: "writing_reminder".tr,
                  isTogol: true,
                  isToggled: controller.isWritingReminderOn.value,
                  onToggleChanged: (value) {
                    controller.toggleWritingReminder(value);
                    if (value) {
                      print('yes');
                    } else {
                      print('no');
                    }
                  },
                  onTap: () {},
                );
              }),
          
              // Language Section with Dropdown
              Text("language".tr, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Obx(() {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: controller.selectedLanguage.value,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        controller.changeLanguage(newValue);
                        print('Language changed to: $newValue');
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'English',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("english".tr, style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Spanish',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("spanish".tr, style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                      /*DropdownMenuItem(
                        value: 'French',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("french".tr, style: const TextStyle(fontSize: 16)),
                        ),
                      ),*/
                    ],
                    underline: const SizedBox(),
                  ),
                );
              }),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("log_out".tr),
                      content: Text("logout_confirmation".tr),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "cancel".tr,
                            style: const TextStyle(color: AppColors.appColor),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Add your logout logic here
                          },
                          child: Text(
                            "log_out".tr,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: SvgPicture.asset('assets/images/auth/logout_logo.svg'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}