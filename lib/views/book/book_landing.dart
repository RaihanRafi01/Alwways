import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/routes.dart';
import 'package:playground_02/widgets/book/bookCard.dart';
import 'package:playground_02/widgets/home/custom_bottom_navigation_bar.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: widget.isEpisode ? "Episodes" : "All Books",
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
        child: Text(isEpisode ? "No episodes found" : "No books found"),
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
              Get.to(BookPageView(title: item.title, bookId: item.id, coverImage: item.coverImage, isEpisode: isEpisode,), arguments: {"episodeIndex": index});
            } else {
              Get.to(
                const BookLandingScreen(isEpisode: true),
                arguments: {'episodes': item.episodes},
              );
            }
          },
          child: BookCard(
            title: item.title,
            coverImage: item.coverImage,
            progress: item.percentage,
            isGrid: true, bookId: item.id, isEpisode: isEpisode,
          ),
        );
      },
    );
  }
}