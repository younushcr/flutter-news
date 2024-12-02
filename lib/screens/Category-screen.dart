import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/article_card.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<String> categories = [
    'Business',
    'Technology',
    'Sports',
    'Health',
    'Entertainment'
  ];
  String _selectedCategory = 'Business';
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    newsProvider.fetchNews(_selectedCategory);
  }

  // Function to sort categories
  void _sortCategories(bool isAscending) {
    setState(() {
      _isAscending = isAscending;
      categories.sort(
        (a, b) => isAscending ? a.compareTo(b) : b.compareTo(a),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CategoryScreen'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              if (value == 'Ascending') {
                _sortCategories(true);
              } else if (value == 'Descending') {
                _sortCategories(false);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Ascending',
                child: Text('Sort by Ascending'),
              ),
              const PopupMenuItem(
                value: 'Descending',
                child: Text('Sort by Descending'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                      newsProvider.fetchNews(category);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedCategory == category
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(category,
                        style: const TextStyle(color: Colors.white)),
                  ),
                );
              }).toList(),
            ),
          ),

          // Articles List
          Expanded(
            child: newsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: newsProvider.articles.length,
                    itemBuilder: (context, index) {
                      return ArticleCard(article: newsProvider.articles[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
