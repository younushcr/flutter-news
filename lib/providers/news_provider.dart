import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class NewsProvider with ChangeNotifier {
  List<Article> _articles = [];
  final List<Article> _favorites = []; // Empty list of favorites
  bool _isLoading = false;
  bool _isDarkMode = false;
  List<Article> _filteredArticles = []; // List for filtered articles

  // Getters
  List<Article> get articles =>
      _filteredArticles.isNotEmpty ? _filteredArticles : _articles;
  List<Article> get favorites => _favorites;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;

  // Fetch news articles based on category
  Future<void> fetchNews(String category) async {
    final url =
        'https://newsapi.org/v2/top-headlines?category=$category&apiKey=1ef0234e36794fc796fb20e2d6589f80';
    _isLoading = true;
    // Notify listeners to show loading state immediately (but outside of the build phase)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['articles'] as List;
        _articles = data.map((json) => Article.fromJson(json)).toList();
        _filteredArticles = List.from(_articles); // Initial filtered list
      }
    } catch (e) {
      print('Error fetching news: $e');
    } finally {
      // Make sure state update happens after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners(); // Notify after frame build completes
      });
    }
  }

  // Toggle dark mode
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    // Notify listeners after build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Sort articles by date or title
  void sortArticles(String criteria) {
    if (criteria == 'Date') {
      _filteredArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    } else if (criteria == 'Title') {
      _filteredArticles.sort((a, b) => a.title.compareTo(b.title));
    }
    // Notify listeners after build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Filter articles by title query and date
  void filterArticles(String titleQuery, String? date) {
    List<Article> filteredList = _articles;

    // Filter by title query if present
    if (titleQuery.isNotEmpty) {
      filteredList = filteredList
          .where((article) =>
              article.title.toLowerCase().contains(titleQuery.toLowerCase()))
          .toList();
    }

    // Filter by date if provided
    if (date != null && date.isNotEmpty) {
      filteredList = filteredList
          .where((article) =>
              article.publishedAt.substring(0, 10) == date) // Format: YYYY-MM-DD
          .toList();
    }

    // Update filtered articles list and notify listeners once
    if (filteredList != _filteredArticles) {
      _filteredArticles = filteredList;
      // Notify listeners after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Toggle the favorite status of an article
  void toggleFavorite(Article article) {
    if (_favorites.contains(article)) {
      _favorites.remove(article);
    } else {
      _favorites.add(article);
    }
    // Ensure notifyListeners happens after build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Check if an article is in favorites
  bool isFavorite(Article article) {
    return _favorites.contains(article);
  }
}
