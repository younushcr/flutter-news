import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class InternalNewsScreen extends StatefulWidget {
  const InternalNewsScreen({Key? key}) : super(key: key);

  @override
  State<InternalNewsScreen> createState() => _InternalNewsScreenState();
}

class _InternalNewsScreenState extends State<InternalNewsScreen> {
  late Database _database;
  List<Map<String, dynamic>> _newsList = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<int> _selectedNewsIds = []; // List to track selected news items
  final List<String> _categories = ['All', 'Business', 'Technology', 'Sports', 'Health', 'Entertainment'];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'news.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE news(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            category TEXT NOT NULL,
            imageUrl TEXT
          )
          ''',
        );
      },
      version: 1,
    );
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    String query = "SELECT * FROM news";
    List<String> args = [];
    if (_selectedCategory != 'All') {
      query += " WHERE category = ?";
      args.add(_selectedCategory);
    }
    if (_searchQuery.isNotEmpty) {
      query += args.isNotEmpty ? " AND" : " WHERE";
      query += " title LIKE ?";
      args.add('%$_searchQuery%');
    }

    final List<Map<String, dynamic>> news = await _database.rawQuery(query, args);
    setState(() {
      _newsList = news;
    });
  }

  Future<void> _addNews(String title, String content, String category, String imageUrl) async {
    await _database.insert(
      'news',
      {'title': title, 'content': content, 'category': category, 'imageUrl': imageUrl},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _fetchNews();
  }

  Future<void> _deleteSelectedNews() async {
    for (int id in _selectedNewsIds) {
      await _database.delete(
        'news',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    _fetchNews();
    setState(() {
      _selectedNewsIds.clear(); // Clear selection after deletion
    });
  }

  Future<void> _updateNews(int id, String title, String content, String category, String imageUrl) async {
    await _database.update(
      'news',
      {'title': title, 'content': content, 'category': category, 'imageUrl': imageUrl},
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchNews();
  }

  void _showEditNewsDialog(BuildContext context, Map<String, dynamic> news) {
    final TextEditingController titleController = TextEditingController(text: news['title']);
    final TextEditingController contentController = TextEditingController(text: news['content']);
    final TextEditingController imageUrlController = TextEditingController(text: news['imageUrl']);
    String selectedCategory = news['category'];

    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Edit News'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              DropdownButtonFormField(
                value: selectedCategory,
                items: _categories
                    .where((c) => c != 'All')
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedCategory = value.toString();
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty &&
                  imageUrlController.text.isNotEmpty) {
                _updateNews(news['id'], titleController.text, contentController.text, selectedCategory, imageUrlController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _getShortDescription(String content) {
    List<String> words = content.split(' ');
    if (words.length > 10) {
      words = words.sublist(0, 10);
      return words.join(' ') + '...';
    } else {
      return content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internal News'),
        actions: [
          if (_selectedNewsIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedNews,
            ),
          if (_selectedNewsIds.length == 1)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                final selectedNews = _newsList.firstWhere((news) => news['id'] == _selectedNewsIds.first);
                _showEditNewsDialog(context, selectedNews); // Show edit dialog for the selected news item
              },
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddNewsDialog(context), // Show add news dialog
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    _fetchNews();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedCategory == category ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(color: _selectedCategory == category ? Colors.white : Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _fetchNews();
              },
            ),
          ),
          // News List
          Expanded(
            child: _newsList.isEmpty
                ? const Center(child: Text('No news found'))
                : ListView.builder(
                    itemCount: _newsList.length,
                    itemBuilder: (context, index) {
                      final news = _newsList[index];
                      final isSelected = _selectedNewsIds.contains(news['id']);
                      return GestureDetector(
                        onLongPress: () {
                          setState(() {
                            if (!_selectedNewsIds.contains(news['id'])) {
                              _selectedNewsIds.add(news['id']);
                            }
                          });
                        },
                        onTap: () {
                          setState(() {
                            if (_selectedNewsIds.contains(news['id'])) {
                              _selectedNewsIds.remove(news['id']);
                            } else {
                              _selectedNewsIds.add(news['id']);
                            }
                          });
                        },
                        child: Card(
                          margin: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 5,
                          color: isSelected ? Colors.blue.withOpacity(0.3) : null, // Light blue for selected items
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: news['imageUrl'] != ''
                                    ? Image.network(
                                        news['imageUrl'],
                                        fit: BoxFit.cover,
                                      )
                                    : const SizedBox(height: 150),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      news['title'],
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getShortDescription(news['content']),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddNewsDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    String selectedCategory = 'Business'; // Default category

    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Add News'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              DropdownButtonFormField(
                value: selectedCategory,
                items: _categories
                    .where((c) => c != 'All')
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedCategory = value.toString();
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty &&
                  imageUrlController.text.isNotEmpty) {
                _addNews(titleController.text, contentController.text, selectedCategory, imageUrlController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
