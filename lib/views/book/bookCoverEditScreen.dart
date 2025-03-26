import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playground_02/controllers/book/book_controller.dart';
import 'package:playground_02/controllers/book/bookChapter_controller.dart';
import 'package:playground_02/widgets/authentication/custom_textField.dart';
import '../../constants/color/app_colors.dart';
import '../../widgets/book/bookCover.dart';
import '../../widgets/customAppBar.dart';

class BookCoverEditScreen extends StatefulWidget {
  final String title;
  final String image;
  final String bookId;
  final bool isEpisode;

  const BookCoverEditScreen({
    super.key,
    required this.title,
    required this.image,
    required this.bookId,
    this.isEpisode = false,
  });

  @override
  _BookCoverEditScreenState createState() => _BookCoverEditScreenState();
}

class _BookCoverEditScreenState extends State<BookCoverEditScreen> {
  late BookController bookController;
  late BookChapterController chapterController;
  String? errorMessage;
  bool isEpisodeEdit = false;
  int episodeIndex = 0;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    print("Initializing BookCoverEditScreen - bookId: ${widget.bookId}, isEpisode: ${widget.isEpisode}");
    bookController = Get.find<BookController>();
    chapterController = Get.put(BookChapterController());
    _checkContent();
  }

  void _checkContent() {
    print("Checking content for bookId: ${widget.bookId}, isEpisode: ${widget.isEpisode}");
    try {
      print("Books: ${bookController.books.map((b) => {'id': b.id, 'episodes': b.episodes.map((e) => {'id': e.id, 'title': e.title}).toList()})}");
      if (widget.isEpisode) {
        final book = bookController.books.firstWhereOrNull((b) => b.episodes.any((e) => e.id == widget.bookId));
        if (book == null) {
          print("Episode ${widget.bookId} not found");
          setState(() {
            errorMessage = "episode_not_found".trParams({'bookId': widget.bookId}); // Updated
          });
          return;
        }
        episodeIndex = book.episodes.indexWhere((e) => e.id == widget.bookId);
        isEpisodeEdit = episodeIndex != -1;
      } else {
        final book = bookController.books.firstWhereOrNull((b) => b.id == widget.bookId);
        if (book == null) {
          print("Book ${widget.bookId} not found");
          setState(() {
            errorMessage = "book_not_found".trParams({'bookId': widget.bookId}); // Updated
          });
          return;
        }
        isEpisodeEdit = false;
        episodeIndex = 0;
      }
      print("Content check passed - isEpisodeEdit: $isEpisodeEdit, episodeIndex: $episodeIndex");
    } catch (e) {
      print("Exception in _checkContent: $e");
      setState(() {
        errorMessage = "error_with_message".trParams({'error': e.toString()}); // Updated
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      bookController.updateCoverImage(widget.bookId, image.path);
      if (isEpisodeEdit) {
        chapterController.allPageImages[episodeIndex] = image.path;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building UI for bookId: ${widget.bookId}");
    if (errorMessage != null) {
      return Scaffold(
        appBar: CustomAppbar(title: "error".tr, showIcon: false), // Updated
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text("go_back".tr), // Updated
              ),
            ],
          ),
        ),
      );
    }

    final TextEditingController titleController = TextEditingController(
      text: bookController.getTitle(widget.bookId),
    );

    ever(bookController.books, (_) {
      final currentTitle = bookController.getTitle(widget.bookId);
      if (titleController.text != currentTitle) {
        titleController.text = currentTitle;
      }
    });

    return Scaffold(
      appBar: CustomAppbar(
        title: isEpisodeEdit ? "edit_episode_cover".tr : "edit_cover".tr, // Updated
        showIcon: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
                  child: Obx(
                        () => BookCover(
                      isGrid: false,
                      isCoverEdit: true,
                      title: bookController.getTitle(widget.bookId),
                      coverImage: isEpisodeEdit
                          ? (chapterController.allPageImages.isNotEmpty
                          ? (chapterController.allPageImages[0] ?? widget.image)
                          : widget.image)
                          : (bookController.getCoverImage(widget.bookId, widget.image)),
                      bookId: widget.bookId,
                      isEpisode: isEpisodeEdit,
                    ),
                  ),
                ),
                if (!isEpisodeEdit)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: CustomTextField(
                      controller: titleController,
                      suffixIcon: Icons.edit,
                      radius: 20,
                      onChanged: (value) {
                        bookController.updateTitle(widget.bookId, value);
                        if (isEpisodeEdit) {
                          chapterController.allPageChapters[episodeIndex] = value;
                        }
                      },
                      label: '',
                    ),
                  ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    "select_background_cover".tr, // Updated
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: bookController.bookCovers.length,
                    itemBuilder: (context, index) {
                      final bookCover = bookController.bookCovers[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            bookController.updateSelectedCover(widget.bookId, bookCover);
                            if (isEpisodeEdit) {
                              chapterController.allPageImages[episodeIndex] = bookCover;
                            }
                          },
                          child: Obx(() {
                            bool isSelected = bookCover == bookController.getBackgroundCover(widget.bookId);
                            return Stack(
                              children: [
                                SvgPicture.asset(
                                  bookCover,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    left: 0,
                                    bottom: 0,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        'assets/images/book/tic_icon.svg',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() => Center(
                  child: ElevatedButton(
                    onPressed: bookController.isLoading.value
                        ? null
                        : () async {
                      if (isEpisodeEdit) {
                        print('::::::::::::::::::::::::::::::: hit episode');
                        await bookController.updateEpisodeCoverApi(widget.bookId, episodeIndex);
                      } else {
                        print('::::::::::::::::::::::::::::::: hit book');
                        await bookController.updateBookCoverApi(widget.bookId);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: bookController.isLoading.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      "save_changes".tr, // Updated
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}