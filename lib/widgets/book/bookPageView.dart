import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
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
    controller.loadStory(bookId, episodeIndex, coverImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: ''),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Expanded(
              child: Obx(() {
                final pageCount = controller.allPages.isEmpty ? 1 : controller.allPages.length + 1;
                return PageView.builder(
                  controller: controller.pageController,
                  itemCount: pageCount,
                  itemBuilder: (context, index) {
                    print("Building page at index: $index, pageCount: $pageCount");
                    print("allPages.length: ${controller.allPages.length}, allPageChapters.length: ${controller.allPageChapters.length}, allPageImages.length: ${controller.allPageImages.length}");
                    if (index == 0) {
                      return Center(
                        child: BookCover(
                          haveTitle: true,
                          isGrid: false,
                          title: title,
                          coverImage: coverImage,
                          bookId: bookId,
                          isEpisode: isEpisode,
                        ),
                      );
                    }
                    final pageIndex = index - 1;
                    if (controller.allPages.isEmpty ||
                        pageIndex >= controller.allPages.length ||
                        pageIndex >= controller.allPageChapters.length ||
                        index >= controller.allPageImages.length) {
                      return const Center(child: Text('No content available'));
                    }
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
                                    'Chapter - 1',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 20),
                                  SvgPicture.asset(
                                    "assets/images/book/chapter_underline_1.svg",
                                    width: 140,
                                  ),
                                  Text(
                                    title,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      controller.allPages[pageIndex],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.bookTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16, right: 16),
                                  child: GestureDetector(
                                    onTap: () async {
                                      final isCover = controller.allPages[pageIndex].contains("ChapterCover");
                                      final result = await Get.to(() => BookEditPage(
                                        index: pageIndex,
                                        chapterTitle: controller.allPageChapters[pageIndex],
                                        chapterContent: controller.allPages[pageIndex],
                                        isCover: isCover,
                                      ));
                                      if (result != null) {
                                        controller.updateChapterTitle(pageIndex, result["title"]);
                                        controller.updateChapterContent(pageIndex, result["content"]);
                                      }
                                    },
                                    child: SvgPicture.asset(
                                      "assets/images/book/edit_icon.svg",
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}