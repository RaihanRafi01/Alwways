import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/views/subscription/cupon_view.dart';
import '../../../constants/color/app_colors.dart';
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
    Get.put(SettingController());

    /*final FlutterSecureStorage _storage = FlutterSecureStorage();
    Future<void> logout() async {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');

      // SharedPreferences

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false); // User is logged out

      Get.offAll(() => AuthenticationView()); // Navigate to the login screen
    }
*/
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontSize: 26)),
        centerTitle: true,),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            //const Text('Settings', style: TextStyle(fontSize: 30)),

            // Account Section
            const Text('Account', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        SettingsList(
          svgPath: 'assets/images/settings/subscription_icon.svg',
          text: 'Manage subscription',
          onTap: () => Get.to(() => const SubscriptionView()),
        ),
        SettingsList(
            svgPath: 'assets/images/settings/delete_icon.svg',
            text: 'Delete Account',
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true, // Prevents closing by tapping outside
                builder: (BuildContext context) {
                  return CustomDeletePopup(
                    title: 'Do you want to delete your account ?\nIt will permanently delete your al user data.',
                    onButtonPressed1: () {
                      // Delete
                    },
                    onButtonPressed2: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  );
                },
              );
            }),
        SettingsList(
          svgPath: 'assets/images/settings/terms_icon.svg',
          text: 'Terms and condition',
          onTap: () => Get.to(() => const TermsPrivacyView(isTerms: true,)),
        ),
        SettingsList(
          svgPath: 'assets/images/settings/privacy_icon.svg',
          text: 'Privacy policy',
          onTap: () => Get.to(() => const TermsPrivacyView(isTerms: false,)),
        ),

        // Help Section
        const Text('Help', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        SettingsList(
          svgPath: 'assets/images/settings/email_icon.svg',
          text: 'Email Support',
          onTap: () =>
              Get.to(() =>  HelpSupportView()), // HelpSupportView()),
              ),

          // Notification Section with Toggle
          const Text('Notification', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Obx(() {
            return SettingsList(
              svgPath: 'assets/images/settings/notification_icon.svg',
              text: 'Writing Reminder',
              isTogol: true,
              isToggled: controller.isWritingReminderOn.value,
              // Correctly passing the toggle value
              onToggleChanged: (value) {
                controller.toggleWritingReminder(value); // Handle toggle change
                if (value) {
                  print('yes'); // Print 'yes' when the toggle is ON
                } else {
                  print('no'); // Print 'no' when the toggle is OFF
                }
              },
              onTap: () {},
            );
          }),
          // Language Section with Dropdown
          const Text('Language', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),

          // DropdownButton with full width and border
          Obx(() {
            return Container(
              width: double.infinity, // Makes the container take up full width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Rounded corners
                border: Border.all(
                  color: Colors.grey, // Border color
                  width: 1, // Border width
                ),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                // Ensures the dropdown takes up all available space
                value: controller.selectedLanguage.value,
                // Bind to reactive variable
                onChanged: (newValue) {
                  if (newValue != null) {
                    controller.changeLanguage(newValue); // Update language
                    print('Language changed to: $newValue'); // Debug print
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: 'English',
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'English',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Spanish',
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Spanish',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'French',
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'French',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  // Add more languages here as needed
                ],
                underline: const SizedBox(), // Removes the default underline of the dropdown
              ),
            );
          }),
          const SizedBox(height: 20,),
          GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        title: const Text('Log Out',),
                        content: const Text(
                            'Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel', style: TextStyle(color: AppColors
                                .appColor),),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Add your logout logic here
                              //logout();
                            },
                            child: const Text(
                                'Log Out', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                );
              },
              child: SvgPicture.asset('assets/images/auth/logout_logo.svg')),
          ],
        ),
      ),
    );
  }
}
