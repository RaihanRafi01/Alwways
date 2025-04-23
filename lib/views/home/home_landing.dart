import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/controllers/home_controller.dart';
import 'package:playground_02/views/chatWithAI/chatScreen.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';
import 'package:playground_02/widgets/book/bookCover.dart';
import '../../constants/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/book/book_controller.dart';
import '../../controllers/chat/botLanding_controller.dart';
import '../chatWithAI/chatLandingScreen.dart';

class HomePageLanding extends StatefulWidget {
  final String? bookId;
  final String? bookTitle;
  final String? coverImage;

  const HomePageLanding({
    super.key,
    this.bookId,
    this.bookTitle,
    this.coverImage,
  });

  @override
  _HomePageLandingState createState() => _HomePageLandingState();
}

class _HomePageLandingState extends State<HomePageLanding> {
  final NavigationController navController = Get.put(NavigationController());
  final HomeController homeController = Get.put(HomeController());
  final AuthController authController = Get.find<AuthController>();
  final BookController bookController = Get.put(BookController());
  final BotController botController = Get.put(BotController());

  @override
  Widget build(BuildContext context) {
    var name = authController.firstName.value;
    String displayTitle = widget.bookTitle ?? "my_life".tr;
    String displayCover = widget.coverImage ?? '';
    String displayBookId = widget.bookId ?? '';

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Center(
                child: BookCover(
                  isGrid: false,
                  title: displayTitle,
                  coverImage: displayCover,
                  bookId: displayBookId,
                  isEpisode: false,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${"hi".tr} $name!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                    () => Text(
                  homeController.message.value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: "TALK TO TITI",
                onPressed: () {
                  if (displayBookId.isNotEmpty) {
                    // Ensure botController has the correct book and section selected
                    botController.selectBook(displayBookId);
                    String sectionId = botController.sections.isNotEmpty
                        ? botController.sections.first.id
                        : '';
                    String episodeId = botController.episodes.isNotEmpty
                        ? botController.episodes.first.id
                        : '';
                    botController.selectSection(sectionId);
                    botController.selectedEpisodeId.value = episodeId;

                    Get.to(() => ChatScreen(
                      bookId: displayBookId,
                      sectionId: sectionId,
                      episodeId: episodeId,
                    ));
                  } else {
                    // Fallback to ChatLandingScreen if no book is provided
                    Get.to(() => ChatLandingScreen());
                  }
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}