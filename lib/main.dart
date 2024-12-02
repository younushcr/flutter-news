import 'package:flutter/material.dart';
// import 'package:newsapp/screens/home_screen.dart';
import 'package:newsapp/bottom-bar/bottom_bar.dart';
import 'package:provider/provider.dart';
import 'providers/news_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NewsProvider(),
      child: Consumer<NewsProvider>(
        builder: (context, newsProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness:
                  newsProvider.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            home: const BottomBar(),
          );
        },
      ),
    );
  }
}
