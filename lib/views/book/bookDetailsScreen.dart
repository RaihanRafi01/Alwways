import 'package:flutter/material.dart';
import 'package:playground_02/widgets/book/bookPageView.dart';
import 'package:playground_02/widgets/chatHeader.dart';

class BookDetailsScreen extends StatelessWidget {

  const BookDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: const CustomAppbar(title: "",isHome: true,),
      body: BookPageView(), // Display the book content
    );
  }
}
