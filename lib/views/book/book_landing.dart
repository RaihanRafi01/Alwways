import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/controllers/book/book_controller.dart';
import 'package:playground_02/widgets/book/bookCard.dart';
import 'package:playground_02/widgets/home/custom_bottom_navigation_bar.dart';
import '../../constants/color/app_colors.dart';
import '../../controllers/book/bookLanding_controller.dart';
import '../../services/model/bookModel.dart';
import '../../widgets/book/bookPageView.dart';
import '../../widgets/customAppBar.dart';

class BookLandingScreen extends StatefulWidget {
  final bool isEpisode;
  const BookLandingScreen({super.key, this.isEpisode = false});

  @override
  State<BookLandingScreen> createState() => _BookLandingScreenState();
}

class _BookLandingScreenState extends State<BookLandingScreen> {
  final NavigationController navController = Get.put(NavigationController());
  final BookLandingController bookController = Get.put(BookLandingController());
  //final bookController1 = Get.find<BookController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CustomAppbar(
        title: widget.isEpisode ? "episodes".tr : "all_books".tr, // Updated
        isHome: !widget.isEpisode,
      ),
      body: Stack(
        children: [
          widget.isEpisode
              ? _buildGrid(Get.arguments['episodes'] as List<Episode>, true)
              : Obx(() {
            if (bookController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildGrid(bookController.books, false);
          }),
          Positioned(
            bottom: 60,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.bookAddScreen);
                print('Floating button clicked!');
              },
              child: SvgPicture.asset(
                'assets/images/book/add_icon.svg',
                height: 50,
                width: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<dynamic> items, bool isEpisode) {
    if (items.isEmpty) {
      return Center(
        child: Text(isEpisode ? "no_episodes_found".tr : "no_books_found".tr), // Updated
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        var item = items[index];
        return GestureDetector(
          onTap: () {
            if (isEpisode) {
              final percentage = item.percentage ?? 0.0;
              final bookId = item.bookId;
              final episodeIndex = index.toString();
              if (percentage != 100.0) {
                print("Episode '${item.title}'");
                print("Episode coverImage '${item.coverImage}'");
                Get.to(
                  BookPageView(
                    title: item.localizedTitle,
                    bookId: bookId,
                    coverImage: item.coverImage ?? 'assets/images/default_cover.jpg',
                    isEpisode: isEpisode,
                    episodeIndex: episodeIndex,
                  ),
                  arguments: {"episodeIndex": episodeIndex},
                );
              } else {
                print(
                    "Episode '${item.title}' cannot be opened. Completion: $percentage% (must be less than 100%)");
              }
            } else {
              final bookId = item.id;
              Get.to(
                const BookLandingScreen(isEpisode: true),
                arguments: {
                  'episodes': item.episodes,
                  'bookId': bookId,
                },
              );
            }
          },
          child: BookCard(
            //title: item.title,
            coverImage: item.coverImage,
            progress: item.percentage,
            isGrid: true,
            bookId: item.id,
            isEpisode: isEpisode,
          ),
        );
      },
    );
  }
}