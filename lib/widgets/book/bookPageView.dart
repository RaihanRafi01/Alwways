import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/widgets/book/bookCover.dart';
import 'package:playground_02/widgets/customAppBar.dart';
import '../../controllers/book/allEpisodes_controller.dart';
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
    print("BookPageView - bookId: $bookId, episodeIndex: $episodeIndex, title: $title, coverImage: $coverImage");
    controller.loadStory(bookId, episodeIndex, coverImage);
  }

  @override
  Widget build(BuildContext context) {
    const storyTextStyle = TextStyle(
      fontSize: 16,
      color: AppColors.bookTextColor,
      height: 1.5,
      fontWeight: FontWeight.normal,
    );

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CustomAppbar(title: title),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.allPages.isEmpty) {
          return const Center(child: Text('No content available'));
        }
        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.allPages.length + 1, // Cover + story pages
                onPageChanged: (index) {
                  controller.currentPage.value = index;
                  print("Page changed to index: $index");
                },
                itemBuilder: (context, index) {
                  print("Building page at index: $index, pageCount: ${controller.allPages.length + 1}");
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
                  if (pageIndex >= controller.allPages.length ||
                      pageIndex >= controller.allPageChapters.length) {
                    return const Center(child: Text('Invalid page index'));
                  }
                  // Relax the check for allPageImages to avoid failure
                  if (pageIndex >= controller.allPageImages.length - 1) {
                    print("Warning: allPageImages too short, expected at least ${pageIndex + 1}, got ${controller.allPageImages.length}");
                  }

                  final storyContent = controller.allPages[pageIndex];
                  final chapterTitle = controller.allPageChapters[pageIndex];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                                  chapterTitle,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 20),
                                SvgPicture.asset(
                                  "assets/images/book/chapter_underline_1.svg",
                                  width: 140,
                                ),
                                const SizedBox(height: 20),
                                if (pageIndex == 0)
                                  Text(
                                    title,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: pageIndex == 0
                                      ? RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style.copyWith(
                                        fontSize: storyTextStyle.fontSize,
                                        color: storyTextStyle.color,
                                        height: storyTextStyle.height,
                                        fontWeight: storyTextStyle.fontWeight,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: storyContent.isNotEmpty ? storyContent[0] : '',
                                          style: storyTextStyle.copyWith(
                                            fontSize: 40,
                                          ),
                                        ),
                                        TextSpan(
                                          text: storyContent.isNotEmpty ? storyContent.substring(1) : '',
                                          style: storyTextStyle,
                                        ),
                                      ],
                                    ),
                                  )
                                      : Text(
                                    storyContent,
                                    style: storyTextStyle,
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
                                    final isCover = storyContent.contains("ChapterCover");
                                    final result = await Get.to(() => BookEditPage(
                                      episodeIndex: int.parse(episodeIndex),
                                      index: pageIndex,
                                      chapterTitle: chapterTitle,
                                      chapterContent: storyContent,
                                      isCover: isCover,
                                    ));
                                    if (result != null) {
                                      await controller.updateChapterTitle(pageIndex, result["title"]);
                                      await controller.updateChapterContent(pageIndex, result["content"]);
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
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }
}