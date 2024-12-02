import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/article_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      setState(() {});
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
        title: const Text('News App'),
        actions: const [
          // IconButton(
          //   icon: Icon(
          //       newsProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          //   onPressed: newsProvider.toggleDarkMode,
          // ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar

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
