import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/widgets/book/bookCover.dart';
import 'package:playground_02/widgets/customAppBar.dart';
import '../../controllers/book/allEpisodes_controller.dart';
import '../../controllers/book/bookChapter_controller.dart';
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

  String _getChapterTitle(AllEpisodesController controller) {
    final currentPage = controller.currentPage.value;
    if (currentPage >= 0 && controller.flatPages.isNotEmpty && currentPage < controller.flatPages.length) {
      final pageData = controller.flatPages[currentPage];
      final episodeIndex = pageData['episodeIndex'] ?? -1;
      final pageIndex = pageData['pageIndex'] ?? -1;
      if (pageData['type'] == 'story' &&
          episodeIndex >= 0 &&
          pageIndex >= 0 &&
          episodeIndex < controller.allPageChapters.length &&
          pageIndex < controller.allPageChapters[episodeIndex].length) {
        return controller.allPageChapters[episodeIndex][pageIndex];
      } else if (pageData['type'] == 'episode_cover' &&
          episodeIndex >= 0 &&
          episodeIndex < controller.episodes.length) {
        return controller.episodes[episodeIndex].localizedTitle;
      }
    }
    return title; // Default to book title for book cover or invalid cases
  }

  @override
  Widget build(BuildContext context) {
    Get.put(BookChapterController());
    return Scaffold(
      backgroundColor: AppColors.bookBackground,
      appBar: CustomAppbar(title: title),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() {
              if (controller.flatPages.isEmpty || controller.isLoading.value) {
                return const SizedBox.shrink();
              }
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _getChapterTitle(controller),
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
            }),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.flatPages.isEmpty) {
                  return const Center(child: Text('No content available'));
                }
                print("Building PageView with ${controller.flatPages.length} pages");
                return PageView.builder(
                  controller: controller.pageController,
                  itemCount: controller.flatPages.length,
                  onPageChanged: (index) {
                    controller.currentPage.value = index;
                    print("Page changed to index: $index");
                  },
                  itemBuilder: (context, index) {
                    print(
                        "Building page at index: $index, total pages: ${controller.flatPages.length}, page data: ${controller.flatPages[index]}");
                    final pageData = controller.flatPages[index];
                    final pageType = pageData['type'];
                    final episodeIndex = pageData['episodeIndex'] ?? -1;
                    final pageIndex = pageData['pageIndex'] ?? -1;

                    if (pageType == 'book_cover') {
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
                      if (episodeIndex < 0 || episodeIndex >= controller.episodes.length) {
                        return const Center(child: Text('Invalid episode index'));
                      }
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
                      if (episodeIndex < 0 ||
                          episodeIndex >= controller.allPages.length ||
                          pageIndex < 0 ||
                          pageIndex >= controller.allPages[episodeIndex].length) {
                        return const Center(child: Text('Invalid story page index'));
                      }
                      final episode = controller.episodes[episodeIndex];
                      final storyContent = controller.allPages[episodeIndex][pageIndex];
                      final chapterTitle = controller.allPageChapters[episodeIndex][pageIndex];
                      final isFirstPage = pageIndex == 0;

                      print("Rendering story page: episode $episodeIndex, page $pageIndex, content: ${storyContent.length > 60 ? storyContent.substring(0, 60) : storyContent}");

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
                                    if (isFirstPage)
                                      Text(
                                        episode.localizedTitle,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: isFirstPage
                                          ? RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: storyContent.isNotEmpty
                                                  ? storyContent[0]
                                                  : '',
                                              style: const TextStyle(
                                                fontSize: 40,
                                                color: AppColors.bookTextColor,
                                              ),
                                            ),
                                            TextSpan(
                                              text: storyContent.isNotEmpty
                                                  ? storyContent.substring(1)
                                                  : '',
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
                                        ));
                                        if (result != null) {
                                          await controller.updateChapterTitle(
                                              episodeIndex, pageIndex, result["title"]);
                                          await controller.updateChapterContent(
                                              episodeIndex, pageIndex, result["content"]);
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
            ),
          ],
        ),
      ),
    );
  }
}