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
import '../../controllers/chat/message_controller.dart';
import '../chatWithAI/chatLandingScreen.dart';
import '../../services/database/databaseHelper.dart';

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
  final MessageController messageController = Get.put(MessageController());
  final DatabaseHelper dbHelper = DatabaseHelper();

  // Observables for dynamic book data
  final RxString displayBookId = ''.obs;
  final RxString displayTitle = ''.obs;
  final RxString displayCover = ''.obs;

  @override
  void initState() {
    super.initState();
    // Fetch the latest book when the widget is initialized
    fetchLatestBook();
  }

  Future<void> fetchLatestBook() async {
    // Fetch all books and sort by updatedAt or createdAt to get the latest
    final books = await dbHelper.getBooks();
    if (books.isNotEmpty) {
      // Sort by updatedAt (or createdAt if updatedAt is not reliable) in descending order
      books.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final latestBook = books.first;
      displayBookId.value = latestBook.id;
      displayTitle.value = latestBook.title;
      displayCover.value = latestBook.coverImage;
      // Update BookController with the latest book
      botController.selectBook(latestBook.id);
      print("Fetched latest book: id=${latestBook.id}, title=${latestBook.title}");
    } else {
      // Fallback to widget parameters or MessageController's bookTitle
      displayBookId.value = widget.bookId ?? '';
      displayTitle.value = widget.bookTitle != null
          ? widget.bookTitle!
          : messageController.bookTitle.value.isNotEmpty
          ? messageController.bookTitle.value
          : "my_life".tr;
      displayCover.value = widget.coverImage ?? '';
      print("No books found, using fallback: title=${displayTitle.value}");
    }
  }

  @override
  Widget build(BuildContext context) {
    var name = authController.firstName.value;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Obx(
                () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Center(
                  child: BookCover(
                    isGrid: false,
                    title: displayTitle.value,
                    coverImage: displayCover.value,
                    bookId: displayBookId.value,
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
                Text(
                  homeController.message.value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: "TALK TO TITI",
                  onPressed: () {
                    if (displayBookId.value.isNotEmpty) {
                      // Ensure botController has the correct book and section selected
                      botController.selectBook(displayBookId.value);
                      String sectionId = botController.sections.isNotEmpty
                          ? botController.sections.first.id
                          : '';
                      String episodeId = botController.episodes.isNotEmpty
                          ? botController.episodes.first.id
                          : '';
                      botController.selectSection(sectionId);
                      botController.selectedEpisodeId.value = episodeId;

                      Get.to(() => ChatScreen(
                        bookId: displayBookId.value,
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
      ),
    );
  }
}