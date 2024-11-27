import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              leading: const Icon(Icons.edit, color: Colors.green),
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to edit profile
              },
            ),

            const Divider(),

            // Email
            ProfileItem(
              icon: Icons.email_outlined,
              title: controller.email,
            ),

            // Phone Number
            ProfileItem(
              icon: Icons.phone_outlined,
              title: controller.phone,
            ),

            // Gender
            ProfileItem(
              icon: Icons.male_outlined,
              title: controller.gender,
            ),

            // Date of Birth
            ProfileItem(
              icon: Icons.cake_outlined,
              title: controller.dob,
            ),

            // Location
            ProfileItem(
              icon: Icons.location_on_outlined,
              title: controller.location,
            ),

            const Divider(),

            // Settings
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.green),
              title: const Text('Settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to settings
              },
            ),

            const SizedBox(height: 20), // Add spacing before logout button

            // Log Out
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                // Log out logic
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
            () => CustomBottomNavigationBar(
          selectedIndex: navController.selectedIndex.value,
          onItemSelected: navController.changePage,
        ),
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const ProfileItem({Key? key, required this.icon, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
    );
  }
}
