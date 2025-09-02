import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:playground_02/constants/color/app_colors.dart';
import 'package:playground_02/controllers/book/book_controller.dart';
import '../../services/database/databaseHelper.dart';
import '../../views/book/allEpisodesView.dart';
import 'bookCover.dart';
import 'bookProgress.dart';
import 'package:http/http.dart' as http;

class BookCard extends StatelessWidget {
  final String coverImage;
  final double progress;
  final bool isGrid;
  final String bookId;
  final bool isEpisode;

  BookCard({
    super.key,
    required this.coverImage,
    required this.progress,
    this.isGrid = false,
    required this.bookId,
    required this.isEpisode,
  }) {
    print("BookCard - coverImage: $coverImage, isEpisode: $isEpisode, bookId: $bookId");
  }

  Future<pw.ImageProvider> _loadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return pw.MemoryImage(response.bodyBytes);
    } else {
      throw Exception('Failed to load image from $url');
    }
  }

  Future<pw.ImageProvider> _loadPngFromAssets(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    return pw.MemoryImage(byteData.buffer.asUint8List());
  }

  Future<List<File>> _generatePdfFiles(String bookId) async {
    print('Starting PDF generation for bookId: $bookId');
    final dbHelper = DatabaseHelper();
    List<File> pdfFiles = [];

    // Load assets
    final fontRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
    final bookUnderlinePng = await _loadPngFromAssets('assets/images/book/book_underline_4x.png');
    final episodeUnderlinePng = await _loadPngFromAssets('assets/images/book/book_underline_4x.png');

    // Styles
    final titleStyle = pw.TextStyle(fontSize: 48, font: fontBold, color: PdfColors.black);
    final headerStyle = pw.TextStyle(fontSize: 32, font: fontBold, color: PdfColors.black);
    final bodyStyle = pw.TextStyle(
      fontSize: 14,
      font: fontRegular,
      color: PdfColors.black,
      lineSpacing: 3,
    );
    final dropCapStyle = pw.TextStyle(
      fontSize: 40,
      font: fontRegular,
      color: PdfColors.black,
    );
    var backgroundColor = PdfColor.fromInt(AppColors.bookBackground.value);

    final commonPageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginLeft: 0,
        marginRight: 0,
        marginTop: 0,
        marginBottom: 0,
      ),
      buildBackground: (pw.Context context) => pw.Container(color: backgroundColor),
    );

    // Fetch book data
    final books = await dbHelper.getBooks();
    final book = books.firstWhere((b) => b.id == bookId, orElse: () => throw Exception('Book not found'));
    print('Fetched episodes for book $bookId: ${book.episodes.map((e) => e.id).toList()}');

    // Load book cover
    pw.ImageProvider? bookCoverImage;
    if (book.coverImage.isNotEmpty) {
      try {
        bookCoverImage = await _loadImage(book.coverImage);
      } catch (e) {
        print('Error loading book cover image: $e');
      }
    }

    // Pre-fetch episode images
    final Map<String, pw.ImageProvider?> episodeImages = {};
    for (var episode in book.episodes) {
      if (episode.coverImage.isNotEmpty && episode.story != null && episode.story!.isNotEmpty) {
        try {
          episodeImages[episode.id] = await _loadImage(episode.coverImage);
        } catch (e) {
          episodeImages[episode.id] = null;
        }
      }
    }

    // Process episodes
    int fileIndex = 1;
    const int maxPagesPerFile = 1000;
    int currentPageCount = 0;

    final pdf = pw.Document();

    // Add title page
    pdf.addPage(
      pw.Page(
        pageTheme: commonPageTheme,
        build: (pw.Context context) => pw.Container(
          color: backgroundColor,
          child: pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(book.title, style: titleStyle, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 20),
                pw.Image(bookUnderlinePng, width: 350),
                pw.SizedBox(height: 30),
                if (bookCoverImage != null)
                  pw.Image(bookCoverImage, width: 300, height: 400),
              ],
            ),
          ),
        ),
      ),
    );
    currentPageCount++;
    print('Added title page, total pages: $currentPageCount');

    for (var episode in book.episodes) {
      if (episode.story != null && episode.story!.isNotEmpty) {
        final episodeCoverImage = episodeImages[episode.id];
        print('Processing episode ${episode.id} with story length: ${episode.story!.length}');

        final List<pw.Widget> episodeContent = [
          pw.Align(
            alignment: pw.Alignment.topCenter,
            child: pw.Column(
              children: [
                pw.Text(episode.localizedTitle, style: headerStyle, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 12),
                pw.Image(episodeUnderlinePng, width: 260),
              ],
            ),
          ),
          pw.SizedBox(height: 25),
          if (episodeCoverImage != null)
            pw.Center(
              child: pw.Image(episodeCoverImage, width: 200, height: 250),
            ),
          pw.SizedBox(height: 25),
        ];

        final paragraphs = episode.story!.split('\n\n');
        print('Episode ${episode.id} has ${paragraphs.length} paragraphs');
        bool isFirstParagraph = true;

        for (final paragraph in paragraphs) {
          if (paragraph.trim().isNotEmpty) {
            if (isFirstParagraph) {
              final firstLetter = paragraph[0];
              final restOfParagraph = paragraph.substring(1);
              episodeContent.add(
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: firstLetter,
                        style: dropCapStyle,
                      ),
                      pw.TextSpan(
                        text: restOfParagraph,
                        style: bodyStyle,
                      ),
                    ],
                  ),
                  textAlign: pw.TextAlign.justify,
                ),
              );
              isFirstParagraph = false;
            } else {
              episodeContent.add(
                pw.Text(
                  paragraph,
                  style: bodyStyle,
                  textAlign: pw.TextAlign.justify,
                ),
              );
            }
            episodeContent.add(pw.SizedBox(height: 12));
            print('Added paragraph of length ${paragraph.length} to episode ${episode.id}');
          }
        }

        pdf.addPage(
          pw.MultiPage(
            pageTheme: commonPageTheme,
            build: (pw.Context context) => [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 25,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: episodeContent,
                ),
              ),
            ],
          ),
        );

        int estimatedPageCount = (episodeContent.length ~/ 20) + 1;
        currentPageCount += estimatedPageCount;
        print('Added MultiPage for episode ${episode.id}, estimated pages: $estimatedPageCount, total pages: $currentPageCount');

        if (currentPageCount >= maxPagesPerFile) {
          final directory = await getApplicationDocumentsDirectory();
          final safeFileName = book.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
          final file = File('${directory.path}/${safeFileName}_stories_part$fileIndex.pdf');
          await file.writeAsBytes(await pdf.save());
          pdfFiles.add(file);
          print('Saved PDF part $fileIndex with $currentPageCount pages');

          fileIndex++;
          currentPageCount = 0;
        }
      } else {
        print('Episode ${episode.id} has no story content');
      }
    }

    if (currentPageCount > 0) {
      final directory = await getApplicationDocumentsDirectory();
      final safeFileName = book.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final file = File('${directory.path}/${safeFileName}_stories_part$fileIndex.pdf');
      await file.writeAsBytes(await pdf.save());
      pdfFiles.add(file);
      print('Saved final PDF part $fileIndex with $currentPageCount pages');
    }

    return pdfFiles;
  }

  Future<void> _generateAndOpenPdf(String bookId) async {
    try {
      final pdfFiles = await _generatePdfFiles(bookId);

      if (pdfFiles.isEmpty) {
        Get.snackbar('warning'.tr, 'no_PDF_files_generated'.tr);
        return;
      }

      final result = await OpenFile.open(pdfFiles.first.path);
      if (result.type != ResultType.done) {
        Get.snackbar('warning'.tr, 'could_not_open_PDF'.tr);
      } else {
        Get.snackbar(
          'success'.tr,
          'pDF_generated_successfully'.tr,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      print('Error generating PDF: $e');
      Get.snackbar('warning'.tr, 'failed_to_generate_PDF'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>();
    return Container(
      height: isGrid ? 270 : 450,
      padding: EdgeInsets.all(isGrid ? 16 : 20),
      decoration: BoxDecoration(
        color: isGrid ? Colors.transparent : AppColors.bookBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isGrid ? Colors.transparent : AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: BookCover(
              isGrid: isGrid,
              isEdit: true,
              title: bookController.getTitle(bookId),
              coverImage: coverImage,
              bookId: bookId,
              isEpisode: isEpisode,
            ),
          ),
          const SizedBox(height: 16),
          BookProgressBar(progress: progress),
          const SizedBox(height: 16),
          if (!isEpisode) // Only show button for books, not episodes
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 22,
                child: ElevatedButton(
                  onPressed: () async {
                    print('${progress == 100 ? "Download" : "View"} Book button pressed for bookId: $bookId');

                    if (progress == 100) {
                      await _generateAndOpenPdf(bookId);
                    } else {
                      // Navigate to AllEpisodesView to view all episodes
                      Get.to(() => AllEpisodesView(
                        title: bookController.getTitle(bookId),
                        bookId: bookId,
                        coverImage: coverImage,
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        progress == 100 ? Icons.file_download_outlined : Icons.visibility_outlined,
                        size: 17,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        progress == 100 ? "download_book".tr : "view_book".tr,
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}