import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_model.dart';
import '../providers/news_provider.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({required this.article, super.key});

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final isFavorite = newsProvider.isFavorite(article);

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5, // Optional: adds a shadow effect
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10), // Optional: rounds the card corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.urlToImage.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.network(
                article.urlToImage,
                fit: BoxFit.cover,
                width: double.infinity, // Full width image
                height: 200, // Optional: set a fixed height for the image
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              article.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16, // Adjusted font size for readability
              ),
              maxLines: 2, // Optional: limits title to 2 lines
              overflow: TextOverflow
                  .ellipsis, // Optional: adds ellipsis for long titles
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              article.description,
              style: const TextStyle(
                fontSize: 14, // Slightly smaller font size for description
              ),
              maxLines: 3, // Optional: limits description to 3 lines
              overflow: TextOverflow
                  .ellipsis, // Optional: adds ellipsis for long descriptions
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  newsProvider.toggleFavorite(article);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
