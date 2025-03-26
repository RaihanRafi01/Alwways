import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/widgets/customAppBar.dart';
import '../../constants/color/app_colors.dart';
import '../../widgets/authentication/custom_button.dart';

class CouponView extends GetView {
  CouponView({super.key});

  final List<String> predefinedCoupons = [
    "DISCOUNT10",
    "FREESHIP",
    "SAVE20",
  ];

  final TextEditingController couponController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "order".tr, bgColor: AppColors.appColor), // Updated
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              color: AppColors.appColor,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Image.asset("assets/images/logo_white.png"),
                      const SizedBox(height: 8),
                      Image.asset("assets/images/app_name_white.png"),
                      const SizedBox(height: 16),
                      Text(
                        "app_name".tr, // Already translated
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Form Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Name Field
                  _buildField(
                    label: "book_name".tr, // Updated
                    child: TextField(
                      decoration: _buildInputDecoration("my_life".tr), // Updated
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Customer Name Field
                  _buildField(
                    label: "customer_name".tr, // Updated
                    child: TextField(
                      decoration: _buildInputDecoration("enter_customer_name".tr), // Updated
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delivery Address Field
                  _buildField(
                    label: "delivery_address".tr, // Updated
                    child: TextField(
                      maxLines: 3,
                      decoration: _buildInputDecoration("enter_delivery_address".tr), // Updated
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price Field
                  _buildField(
                    label: "price".tr, // Updated
                    child: TextField(
                      readOnly: true,
                      decoration: _buildInputDecoration('\$50'), // Kept as-is; see notes
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Coupon Code Field
                  _buildField(
                    label: "coupon_code".tr, // Updated
                    child: TextField(
                      controller: couponController,
                      readOnly: true,
                      decoration: _buildInputDecoration("add_coupon_code".tr), // Updated
                      onTap: () {
                        _showCouponDialog(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  Divider(color: AppColors.appColor),

                  const SizedBox(height: 16),

                  // Total Price Display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "total_price".tr, // Updated
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '\$40', // Kept as-is; see notes
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Order Now Button
                  Center(
                    child: CustomButton(
                      text: "order_now".tr, // Updated
                      onPressed: () {
                        // Add order logic here
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to show predefined coupon dialog
  void _showCouponDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("select_a_coupon".tr), // Updated
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: predefinedCoupons.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(predefinedCoupons[index]),
                  onTap: () {
                    couponController.text = predefinedCoupons[index];
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("cancel".tr), // Updated
            ),
          ],
        );
      },
    );
  }

  // Helper method to build fields with labels
  Widget _buildField({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$label:', // Colon kept as part of UI, not translated
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: child,
          ),
        ),
      ],
    );
  }

  // Helper method to build InputDecoration with custom borders
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: AppColors.borderColor, // Default border color
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          color: AppColors.borderColor,
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(
          color: AppColors.borderColor,
          width: 1.5,
        ),
      ),
    );
  }
}