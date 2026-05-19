import 'package:flutter/material.dart';

class PageListScreen extends StatelessWidget {
  const PageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Select a page from the sidebar\nor create a new one.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
