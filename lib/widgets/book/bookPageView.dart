import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/widgets/authentication/custom_button.dart';

class BookPageView extends StatefulWidget {
  const BookPageView({super.key});

  @override
  _BookPageViewState createState() => _BookPageViewState();
}

class _BookPageViewState extends State<BookPageView> {
  final PageController _pageController = PageController();
  int _currentPage = 0; // Track the current page index

  final List<String> bookChapter = [
    "Introduction to the Book",
    "Chapter 1 Overview",
    "Chapter 2 Deep Dive",
    "Chapter 3 Analysis",
    "Conclusion"
  ];

  final List<String> bookContent = [
    "Writing this book is important to me because I want my family to understand my past life .By sharing my experiences, I hope to create a meaningful connection with them.",
    "Page 2 Content: Chapter 1 Overview",
    "Page 3 Content: Chapter 2 Deep Dive",
    "Page 4 Content: Chapter 3 Analysis",
    "Page 5 Content: Conclusion"
  ];

  @override
  void initState() {
    super.initState();
    // Listen to page changes and update the _currentPage index
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.toInt();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Static design at the top (e.g., Image, Title, etc.)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Title or other static design
                Text(
                  bookChapter[_currentPage],
                  // Display chapter title based on the current page index
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Description under the title
                Container(
                  color: AppColors.bookBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/images/book/pencil_icon.svg",
                            height: 20, width: 20),
                        const SizedBox(width: 20),
                        const Flexible(
                          child: Text(
                            "New chapters will be added and existing chapters will change as you chat with the AI Bot.",
                            overflow: TextOverflow
                                .clip, // Optional: adds an ellipsis if text overflows
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // PageView with dynamic content
          Expanded(
            child: PageView.builder(
              controller: _pageController, // Use PageController
              itemCount: bookContent.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  child: Container(
                    color: AppColors.bookBackground,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // Pushes content to top and bottom
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              const Text('Foreword',
                                  style: TextStyle(fontSize: 10)),
                              const SizedBox(height: 20),
                              SvgPicture.asset(
                                  "assets/images/book/chapter_underline_1.svg",
                                  width: 100),
                              const SizedBox(height: 30),
                              const Text('Motivation',
                                  style: TextStyle(fontSize: 16)),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: RichText(
                                  textAlign: TextAlign.start,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: bookContent[index][0],
                                        // First letter
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: AppColors
                                              .bookTextColor, // Bigger first letter
                                        ),
                                      ),
                                      TextSpan(
                                        text: bookContent[index].substring(1),
                                        // Remaining text
                                        style: const TextStyle(
                                          fontSize: 8,
                                          color: AppColors.bookTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bottom right icon
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(bottom: 16, right: 16),
                            child: GestureDetector(
                              onTap: (){},
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
                );
              },
            ),
          ),
          // Button at the bottom of the screen
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
                text: "Get Book",
                onPressed: () {
                  // Add your logic here for what happens when the button is pressed
                }),
          ),
        ],
      ),
    );
  }
}
