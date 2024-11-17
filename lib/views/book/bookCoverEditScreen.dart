import 'package:flutter/material.dart';
import 'package:playground_02/widgets/customAppBar.dart';

import '../../widgets/book/bookCoverEdit.dart';

class BookCoverEditScreen extends StatelessWidget {

  const BookCoverEditScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      appBar: CustomAppbar(title: "Edit Cover",showIcon: false),
      body: Bookcoveredit(), // Display the book content
    );
  }
}
