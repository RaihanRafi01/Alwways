import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/views/dashboard/views/dashboard_view.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/authentication/custom_textField.dart';
import 'package:playground_02/widgets/customAppBar.dart';

import '../../constants/color/app_colors.dart';
import '../../constants/routes.dart';
import '../dashboard/controllers/dashboard_controller.dart';

class AddBook extends StatelessWidget {
  const AddBook({super.key});

  @override
  Widget build(BuildContext context) {
    //final DashboardController dashboardController = Get.put(DashboardController());
    return Scaffold(
      appBar: const CustomAppbar(title: "Create a Book",showIcon: false),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CustomTextField(label: "Book Name",textColor: AppColors.textColor),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomButton(text: "create", onPressed: (){
          //dashboardController.currentIndex.value = 1;
          Get.offAll(const DashboardView(index: 1,));
        }),
      ),
    );
  }
}
