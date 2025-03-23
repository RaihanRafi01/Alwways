import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/views/book/bookCoverEditScreen.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/book/bookCover.dart';
import 'package:playground_02/widgets/customAppBar.dart';
import '../../controllers/book/bookChapter_controller.dart';
import '../../views/book/bookPageEditScreen.dart';

class BookPageView extends StatelessWidget {
  final BookChapterController controller = Get.put(BookChapterController());
  final String title;
  final String bookId;
  final String coverImage;
  final bool isEpisode;
  final String episodeIndex;

  BookPageView({
    super.key,
    required this.title,
    required this.bookId,
    required this.coverImage,
    required this.isEpisode,
    required this.episodeIndex,
  }) {
    print("BookPageView - Raw Get.arguments: ${Get.arguments}");
    print("BookPageView - bookId: $bookId, episodeIndex: $episodeIndex");
    print("BookPageView - episode name: $title");
    print("BookPageView - coverImage: $coverImage");
    controller.loadStory(bookId, episodeIndex,coverImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: ''),
      body: Column(
        children: [
          Obx(() {
            if (controller.currentPage.value != 0) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      controller.allPageChapters[controller.currentPage.value - 1],
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                              width: 20,
                            ),
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
            child: Obx(() => PageView.builder(
              controller: controller.pageController,
              itemCount: controller.allPages.isEmpty ? 1 : controller.allPages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        BookCover(
                          haveTitle: true,
                          isGrid: false,
                          title: title,
                          coverImage: coverImage,
                          bookId: bookId,
                          isEpisode: isEpisode,
                        ),
                        /*Padding(
                          padding: const EdgeInsets.only(top: 210, right: 16),
                          child: GestureDetector(
                            onTap: () => Get.to(BookCoverEditScreen(
                              title: title,
                              image: coverImage,
                              bookId: bookId,
                              isEpisode: isEpisode,
                            )),
                            child: SvgPicture.asset(
                              "assets/images/book/edit_icon.svg",
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                    child: Container(
                      color: AppColors.bookBackground,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const SizedBox(height: 30),
                                Text(
                                  controller.allPageChapters[index - 1],
                                  style: const TextStyle(fontSize: 10),
                                ),
                                const SizedBox(height: 20),
                                SvgPicture.asset(
                                  "assets/images/book/chapter_underline_1.svg",
                                  width: 100,
                                ),
                                Obx(() {
                                  final imagePath = controller.allPageImages[index];
                                  if (imagePath != null) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Image.file(
                                        File(imagePath),
                                        height: 100,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    controller.allPages[index - 1],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppColors.bookTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            )),
          ),
        ],
      ),
    );
  }
}