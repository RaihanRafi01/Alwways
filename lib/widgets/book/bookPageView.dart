import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/book/bookCover.dart';
import '../../controllers/book/bookChapter_controller.dart';
import '../../views/book/bookPageEditScreen.dart';

class BookPageView extends StatelessWidget {
  final BookChapterController controller = Get.put(BookChapterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Display chapter info only when currentPage is not 0
          Obx(() {
            if (controller.currentPage.value != 0) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      controller.allPageChapters[controller.currentPage.value],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      color: AppColors.bookBackground,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                                "assets/images/book/pencil_icon.svg",
                                height: 20,
                                width: 20),
                            const SizedBox(width: 20),
                            const Flexible(
                              child: Text(
                                "New chapters will be added and existing chapters will change as you chat with the AI Bot.",
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              itemCount: controller.allPages.length,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Book cover page
                  return Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const BookCover(isGrid: false),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 130, right: 16),
                          child: GestureDetector(
                            onTap: () =>
                                Get.toNamed(AppRoutes.bookCoverEditScreen),
                            child: SvgPicture.asset(
                              "assets/images/book/edit_icon.svg",
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                else {
                  // Chapter pages
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                    child: Container(
                      color: AppColors.bookBackground,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const SizedBox(height: 30),
                              Text(controller.allPageChapters[index],
                                  style: const TextStyle(fontSize: 10)),
                              const SizedBox(height: 20),
                              SvgPicture.asset(
                                  "assets/images/book/chapter_underline_1.svg",
                                  width: 100),
                              const SizedBox(height: 30),
                              const Text('Motivation',
                                  style: TextStyle(fontSize: 16)),
                              Obx(() {
                                final imagePath = controller.allPageImages[index];
                                if (imagePath != null) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Image.file(
                                      File(imagePath),
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink(); // Empty space if no image
                              }),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: RichText(
                                  textAlign: TextAlign.start,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: controller.allPages[index]
                                            [0],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: AppColors.bookTextColor),
                                      ),
                                      TextSpan(
                                        text: controller.allPages[index]
                                            .substring(1),
                                        style: const TextStyle(
                                            fontSize: 8,
                                            color: AppColors.bookTextColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 16, right: 16),
                              child: GestureDetector(
                                onTap: () async {
                                  final isCover = controller.allPages[index].contains("ChapterCover");
                                  final result =
                                      await Get.to(() => BookEditPage(
                                        index: index,
                                            chapterTitle:
                                                controller.allPageChapters[index],
                                            chapterContent:
                                            controller.allPages[index],
                                        isCover: isCover,
                                          ));
                                  if (result != null) {
                                    controller.allPageChapters[index] =
                                        result["title"];
                                    controller.allPages[index] =
                                        result["content"];
                                  }
                                },
                                child: SvgPicture.asset(
                                    "assets/images/book/edit_icon.svg",
                                    height: 24,
                                    width: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              text: "Get Book",
              onPressed: () {
                // Add logic for the button
              },
            ),
          ),
        ],
      ),
    );
  }
}
