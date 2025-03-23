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
import 'bookCover.dart';
import 'bookProgress.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String coverImage;
  final double progress;
  final bool isGrid;
  final String bookId;
  final bool isEpisode;

  const BookCard({
    super.key,
    required this.title,
    required this.coverImage,
    required this.progress,
    this.isGrid = false,
    required this.bookId,
    required this.isEpisode,
  });

  // Function to generate and save PDF with tracing
  Future<void> _generateAndOpenPdf(String bookId) async {
    print('Starting PDF generation for bookId: $bookId');
    final dbHelper = DatabaseHelper();
    final pdf = pw.Document();

    // Load custom fonts
    print('Loading fonts...');
    final fontRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
    print('Fonts loaded successfully: Roboto-Regular and Roboto-Bold');


    // Define text styles
    final titleStyle = pw.TextStyle(
      fontSize: 40,
      font: fontBold,
      color: PdfColors.black,
    );
    final headerStyle = pw.TextStyle(
      fontSize: 24,
      font: fontBold,
      color: PdfColors.black,
    );
    final bodyStyle = pw.TextStyle(
      fontSize: 16,
      font: fontRegular,
      color: PdfColors.black,
      lineSpacing: 1.2,
    );

    // Define background color
    var backgroundColor = PdfColor.fromInt(AppColors.bookBackground1.value);

    final commonPageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginLeft: 0,
        marginRight: 0,
        marginTop: 0,
        marginBottom: 0,
      ),
      buildBackground: (pw.Context context) => pw.Container(
        color: backgroundColor, // Cyan background
      ),
    );

    // Fetch the book and its episodes from the database
    print('Fetching books from database...');
    final books = await dbHelper.getBooks();
    print('Total books fetched: ${books.length}');
    final book = books.firstWhere((b) => b.id == bookId, orElse: () {
      print('Book with ID $bookId not found in database');
      throw Exception('Book not found');
    });
    print('Book found: ${book.title} (ID: ${book.id}) with ${book.episodes.length} episodes');

    // Add first page with only book title
    pdf.addPage(
      pw.Page(
        pageTheme: commonPageTheme,
        build: (pw.Context context) => pw.Center(
          child: pw.Text(
            book.title,
            style: titleStyle,
          ),
        ),
      ),
    );

    // Add all episodes in a MultiPage starting from page 2
    if (book.episodes.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageTheme: commonPageTheme,
          build: (pw.Context context) {
            final List<pw.Widget> content = [];

            for (var episode in book.episodes) {
              if (episode.story != null && episode.story!.isNotEmpty) {
                print('Processing episode: ${episode.id} - Title: ${episode.title}');
                print('Episode story length: ${episode.story?.length ?? 0} characters');

                content.add(
                  pw.Center(
                    child: pw.Text(
                      episode.title,
                      style: headerStyle,
                    ),
                  ),
                );
                content.add(pw.SizedBox(height: 20));

                final paragraphs = episode.story!.split('\n\n');
                for (final paragraph in paragraphs) {
                  if (paragraph.trim().isNotEmpty) {
                    content.add(
                      pw.Text(
                        paragraph,
                        style: bodyStyle,
                        textAlign: pw.TextAlign.justify,
                      ),
                    );
                    content.add(pw.SizedBox(height: 8));
                  }
                }
                content.add(pw.SizedBox(height: 40));
              } else {
                print('Skipping episode ${episode.id} - No story content');
              }
            }

            if (content.isEmpty) {
              content.add(
                pw.Text(
                  'No episode content available',
                  style: bodyStyle,
                ),
              );
            }

            return [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: content,
                ),
              )
            ];
          },
        ),
      );
    }

    // Save the PDF to the device
    print('Saving PDF...');
    final directory = await getApplicationDocumentsDirectory();
    print('Document directory: ${directory.path}');
    final safeFileName = book.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final file = File('${directory.path}/${safeFileName}_stories.pdf');
    print('PDF file path: ${file.path}');
    await file.writeAsBytes(await pdf.save());
    print('PDF saved successfully');

    // Open the PDF file
    print('Attempting to open PDF...');
    final result = await OpenFile.open(file.path);
    print('OpenFile result: ${result.type}, message: ${result.message}');
    if (result.type != ResultType.done) {
      Get.snackbar('Error', 'Could not open PDF: ${result.message}');
    } else {
      Get.snackbar('Success', 'PDF generated and opened successfully!');
    }
  }
  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => BookController());
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
              title: title,
              coverImage: coverImage,
              bookId: bookId,
              isEpisode: isEpisode,
            ),
          ),
          const SizedBox(height: 16),
          BookProgressBar(progress: progress),
          const SizedBox(height: 16),
          if (progress != 100)
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 22,
                child: ElevatedButton(
                  onPressed: () async {
                    print('Download Book button pressed for bookId: $bookId');
                    await _generateAndOpenPdf(bookId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.file_download_outlined,
                        size: 17,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Download Book',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
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