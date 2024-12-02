import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';

class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    return IconButton(
      icon: Icon(
        newsProvider.isDarkMode
            ? Icons.dark_mode
            : Icons.light_mode, // Dark and Light Mode icons
        color: newsProvider.isDarkMode
            ? Colors.white
            : Colors.black, // Color based on mode
      ),
      onPressed: newsProvider.toggleDarkMode, // Toggle dark mode
    );
  }
}
