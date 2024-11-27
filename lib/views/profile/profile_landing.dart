import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playground_02/views/authentication/signup_screen.dart';
import 'package:playground_02/views/setting/views/setting_view.dart';
import 'package:playground_02/widgets/customAppBar.dart';

import '../../constants/routes.dart';
import '../../widgets/authentication/profileImage.dart';
import '../../widgets/home/custom_bottom_navigation_bar.dart';

class ProfileController extends GetxController {
  // Example state variables
  String name = 'Rafsun Hossen';
  String email = 'rafsun121@gmail.com';
  String phone = '+555012855465';
  String gender = 'Male';
  String dob = '27/05/2000';
  String location = 'London park, UK';

  // Reactive variable for the profile image
  Rx<XFile?> pickedImage = Rx<XFile?>(null);

  // Function to pick an image from the gallery
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      pickedImage.value = image; // Update the reactive variable
    }
  }
}

class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());
  final NavigationController navController = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: 'Profile',isHome: true,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Profile Picture and Name
            Center(
              child: Column(
                children: [
                  Obx(
                        () => ProfileImage(
                      image: controller.pickedImage.value,
                      onTap: controller.pickImage,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    controller.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Edit Profile Section
            ListTile(
              leading: SvgPicture.asset("assets/images/profile/profile_edit_icon.svg"),
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.to(()=> const SignupScreen(isEdit: true,title: 'Edit Profile',));
                // Navigate to edit profile
              },
            ),

            // Email
            ProfileItem(
              svgPath: "assets/images/profile/email_icon.svg",
              title: controller.email,
            ),

            // Phone Number
            ProfileItem(
              svgPath: "assets/images/profile/phone_icon.svg",
              title: controller.phone,
            ),

            // Gender
            ProfileItem(
              svgPath: "assets/images/profile/gender_icon.svg",
              title: controller.gender,
            ),

            // Date of Birth
            ProfileItem(
              svgPath: "assets/images/profile/dob_icon.svg",
              title: controller.dob,
            ),

            // Location
            ProfileItem(
              svgPath: "assets/images/profile/location_icon.svg",
              title: controller.location,
            ),

            GestureDetector(
              onTap: (){
                Get.to(()=> const SettingView());
              },
              child: const ProfileItem(
                svgPath: "assets/images/profile/setting_icon.svg",
                title: "Settings",
              ),
            ),


            //const SizedBox(height: 20), // Add spacing before logout button

            // Log Out
            ListTile(
              leading: SvgPicture.asset("assets/images/profile/log_out_icon.svg"),
              title: const Text(
                'Log Out',
              ),
              onTap: () {
                // Log out logic
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
      /*bottomNavigationBar: Obx(
            () => CustomBottomNavigationBar(
          selectedIndex: navController.selectedIndex.value,
          onItemSelected: navController.changePage,
        ),
      ),*/
    );
  }
}

class ProfileItem extends StatelessWidget {
  final String svgPath;
  final String title;

  const  ProfileItem({Key? key, required this.svgPath, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(svgPath),
      title: Text(title),
    );
  }
}
