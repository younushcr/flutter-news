import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/article_card.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> categories = [
    'Business',
    'Technology',
    'Sports',
    'Health',
    'Entertainment'
  ];
  final String _selectedCategory = 'Business';

  @override
  void initState() {
    super.initState();
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    newsProvider.fetchNews(_selectedCategory);
  }

  void _filterArticles(String query) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    if (query.isEmpty) {
      newsProvider.fetchNews(
          _selectedCategory); // Fetch original data if the search is empty
    } else {
      setState(() {
        newsProvider.articles.retainWhere(
          (article) =>
              article.title.toLowerCase().contains(query.toLowerCase()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Screen'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search news...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          // Submit Button to trigger search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                _filterArticles(_searchController.text);
              },
              child: const Text('Submit'),
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
