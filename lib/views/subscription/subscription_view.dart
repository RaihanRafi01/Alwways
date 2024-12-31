import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../constants/color/app_colors.dart';
import '../../widgets/authentication/custom_button.dart';

class SubscriptionView extends GetView {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColors.appColor, // Set your desired background color here
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Image.asset("assets/images/logo_white.png"),
                      const SizedBox(height: 8),
                      Image.asset("assets/images/app_name_white.png"),
                      const SizedBox(height: 16),
                      Text(
                        "app_name".tr,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26,vertical: 10),
              child: _buildPlanCard(
                title: 'Upgrade to Premium',
                features: [
                  'Unlimited chat with the AI Chat Bot.',
                  'Access Full Book.',
                  '200 images in  Book.',
                  'Downloadable soft copy Pdf book.',
                  '\$10 off on physical book.',
                ],
                price: 'Lifetime Access 20\$',
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomButton(text: 'Upgrade now', onPressed: (){}),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required List<String> features,
    required String price,
  }) {
    return Card(
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: AppColors.appColor,
          width: 2.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.appColor,
              ),
            ),
            const SizedBox(height: 10),
            ...features.map((feature) {
              return Row(
                children: [
                  SvgPicture.asset('assets/images/settings/tic_icon.svg'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(feature),
                    ),
                  ),
                ],
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bookBackground,
                side: const BorderSide(color: AppColors.appColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
              ),
              onPressed: () {
                // Handle button press
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lifetime Access',
                    style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.bookTextColor),
                  ),
                  Text(
                    '20\$',
                    style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}