import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/widgets/book/bookCover.dart';
import 'package:playground_02/widgets/customAppBar.dart';
import '../../controllers/book/allEpisodes_controller.dart';
import '../../views/book/bookPageEditScreen.dart';

class AllEpisodesView extends StatelessWidget {
  final AllEpisodesController controller = Get.put(AllEpisodesController());
  final String title;
  final String bookId;
  final String coverImage;

  AllEpisodesView({
    super.key,
    required this.title,
    required this.bookId,
    required this.coverImage,
  }) {
    print("AllEpisodesView - bookId: $bookId, title: $title, coverImage: $coverImage");
    controller.loadAllEpisodes(bookId, title, coverImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: title),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.flatPages.isEmpty) {
          return const Center(child: Text('No content available'));
        }
        return PageView.builder(
          controller: controller.pageController,
          itemCount: controller.flatPages.length,
          itemBuilder: (context, index) {
            print("Building page at index: $index, total pages: ${controller.flatPages.length}");
            final pageData = controller.flatPages[index];
            final pageType = pageData['type'];
            final episodeIndex = pageData['episodeIndex'] ?? -1;
            final pageIndex = pageData['pageIndex'] ?? -1;

            if (pageType == 'book_cover') {
              // Book cover page
              return Center(
                child: BookCover(
                  haveTitle: true,
                  isGrid: false,
                  title: title,
                  coverImage: coverImage,
                  bookId: bookId,
                  isEpisode: false,
                ),
              );
            } else if (pageType == 'episode_cover') {
              // Episode cover page
              final episode = controller.episodes[episodeIndex];
              return Center(
                child: BookCover(
                  haveTitle: true,
                  isGrid: false,
                  title: episode.localizedTitle,
                  coverImage: episode.coverImage ?? coverImage,
                  bookId: bookId,
                  isEpisode: true,
                ),
              );
            } else if (pageType == 'story') {
              // Story page
              final episode = controller.episodes[episodeIndex];
              final storyContent = controller.allPages[episodeIndex][pageIndex];
              final chapterTitle = controller.allPageChapters[episodeIndex][pageIndex];
              final isFirstPage = pageIndex == 0;

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
                              chapterTitle,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            SvgPicture.asset(
                              "assets/images/book/chapter_underline_1.svg",
                              width: 140,
                            ),
                            const SizedBox(height: 20),
                            if (isFirstPage) // Show episode title on first story page
                              Text(
                                episode.localizedTitle,
                                style: const TextStyle(fontSize: 20),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: isFirstPage // Apply drop cap to first story page
                                  ? RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: storyContent.isNotEmpty ? storyContent[0] : '',
                                      style: const TextStyle(
                                        fontSize: 40,
                                        color: AppColors.bookTextColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text: storyContent.isNotEmpty ? storyContent.substring(1) : '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.bookTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : Text(
                                storyContent,
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
                                final isCover = storyContent.contains("ChapterCover");
                                final result = await Get.to(() => BookEditPage(
                                  index: pageIndex,
                                  chapterTitle: chapterTitle,
                                  chapterContent: storyContent,
                                  isCover: isCover,
                                  //episodeIndex: episodeIndex.toString(),
                                ));
                                if (result != null) {
                                  controller.updateChapterTitle(episodeIndex, pageIndex, result["title"]);
                                  controller.updateChapterContent(episodeIndex, pageIndex, result["content"]);
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
            }
            return const Center(child: Text('Invalid page type'));
          },
        );
      }),
    );
  }
}