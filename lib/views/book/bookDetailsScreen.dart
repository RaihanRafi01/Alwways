import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/views/subscription/cupon_view.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/book/bookPageView.dart';
import 'package:playground_02/widgets/customAppBar.dart';

import '../../constants/routes.dart';
import '../../widgets/book/bookCover.dart';

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        title: "",
        isHome: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 50,),
              const BookCover(isGrid: false, title: '', coverImage: '', bookId: '', isEpisode: false,),
              /*Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const BookCover(isGrid: false),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, right: 16),
                      child: GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.bookCoverEditScreen),
                        child: SvgPicture.asset(
                          "assets/images/book/edit_icon.svg",
                          height: 24,
                          width: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),*/
              SizedBox(height: 20,),
              CustomButton(text: 'VIEW BOOK', onPressed: (){
                Get.to(BookPageView(title: 'gfd', bookId: '', coverImage: '', isEpisode: false,));
              }),
              SizedBox(height: 20,),
              CustomButton(text: 'GET BOOK', onPressed: (){
                Get.to(CouponView());
              }),
            ],
          ),
        ),
      ), // Display the book content
    );
  }
}
