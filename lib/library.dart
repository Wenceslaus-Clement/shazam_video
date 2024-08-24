// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For encoding and decoding JSON
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'themenotifier.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<HistoryItem> _historyItems = [];
  List<Map<String, String>> watchlistMovies = [];
  bool _isLoadingHistory = true; // Separate loading states
  bool _isLoadingWatchlist = true;
  bool _isErrorHistory = false;
  bool _isErrorWatchlist = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadWatchlistMovies();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString('historyItems');
      if (historyString != null) {
        final historyJson = jsonDecode(historyString) as List;
        setState(() {
          _historyItems =
              historyJson.map((item) => HistoryItem.fromJson(item)).toList();
        });
      }
    } catch (error) {
      debugPrint('Error loading history: $error');
      _showErrorDialog('Failed to load search history. Please try again.');
      setState(() {
        _isErrorHistory = true;
      });
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _loadWatchlistMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlist = prefs.getStringList('watchlist') ?? [];

      List<Map<String, String>> loadedMovies = [];
      for (String movieId in watchlist) {
        final movie = await _fetchMovieDetails(movieId);
        if (movie != null) {
          loadedMovies.add({
            'title': movie['title'] ?? 'Unknown',
            'poster_path': movie['poster_path'] ?? '',
          });
        }
      }

      setState(() {
        watchlistMovies = loadedMovies;
      });
    } catch (error) {
      debugPrint('Error loading watchlist: $error');
      _showErrorDialog('Failed to load watchlist. Please try again.');
      setState(() {
        _isErrorWatchlist = true;
      });
    } finally {
      setState(() {
        _isLoadingWatchlist = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchMovieDetails(String movieId) async {
    final String apiUrl = 'https://api.themoviedb.org/3/movie/$movieId';
    const String apiKey = 'f6f74d3416647ac0ebd60667187fa8b8'; // TMDB API key

    try {
      final response = await http.get(Uri.parse('$apiUrl?api_key=$apiKey'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching movie details: $e');
      return null;
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _historyItems.map((item) => item.toJson()).toList();
      await prefs.setString('historyItems', jsonEncode(historyJson));
    } catch (error) {
      debugPrint('Error saving history: $error');
      _showErrorDialog('Failed to save history. Please try again.');
    }
  }

  // ignore: unused_element
  void _addHistoryItem(HistoryItem item) {
    setState(() {
      _historyItems.add(item);
      _saveHistory();
    });
  }

  void _removeHistoryItem(int index) {
    setState(() {
      _historyItems.removeAt(index);
      _saveHistory();
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshWatchlist() async {
    setState(() {
      _isLoadingWatchlist = true;
      _isErrorWatchlist = false;
    });
    await _loadWatchlistMovies();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        context.watch<ThemeNotifier>().themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Library'),
        backgroundColor: isDarkMode ? Colors.black : Colors.blue,
      ),
      body: _isLoadingHistory && _isLoadingWatchlist
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshWatchlist,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_isErrorHistory)
                    _buildErrorState('Failed to load search history.')
                  else if (_historyItems.isEmpty)
                    _buildEmptyState('No searches yet', isDarkMode)
                  else
                    _buildHistoryList(isDarkMode),
                  const SizedBox(height: 20),
                  if (_isErrorWatchlist)
                    _buildErrorState('Failed to load watchlist.')
                  else if (watchlistMovies.isEmpty)
                    _buildEmptyState('No movies in watchlist', isDarkMode)
                  else
                    _buildWatchlist(isDarkMode),
                ],
              ),
            ),
    );
  }

  Widget _buildHistoryList(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search History',
          style: TextStyle(
            fontSize: 20,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _historyItems.length,
          itemBuilder: (context, index) {
            final item = _historyItems[index];
            return Dismissible(
              key: Key('history_$index'),
              onDismissed: (direction) {
                _removeHistoryItem(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History item removed')),
                );
              },
              background: Container(color: Colors.red),
              child: Column(
                children: [
                  HistoryItemWidget(
                    item.title,
                    item.year,
                    item.timeAgo,
                  ),
                  Divider(
                    thickness: 2,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWatchlist(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Watchlist',
          style: TextStyle(
            fontSize: 20,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: watchlistMovies.length,
          itemBuilder: (context, index) {
            final movie = watchlistMovies[index];
            return ListTile(
              leading: CachedNetworkImage(
                imageUrl:
                    'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
                width: 50,
                height: 75,
              ),
              title: Text(
                movie['title']!,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, bool isDarkMode) {
    return Column(
      children: [
        Icon(Icons.hourglass_empty,
            color: isDarkMode ? Colors.white : Colors.black, size: 50),
        const SizedBox(height: 8),
        Text(
          message,
          style: TextStyle(
            fontSize: 18,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Column(
      children: [
        Icon(Icons.error, color: Colors.red, size: 50),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}

class HistoryItem {
  final String title;
  final String year;
  final String timeAgo;

  HistoryItem({
    required this.title,
    required this.year,
    required this.timeAgo,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      title: json['title'],
      year: json['year'],
      timeAgo: json['timeAgo'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'year': year,
        'timeAgo': timeAgo,
      };
}

class HistoryItemWidget extends StatelessWidget {
  final String title;
  final String year;
  final String timeAgo;

  const HistoryItemWidget(this.title, this.year, this.timeAgo, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        context.watch<ThemeNotifier>().themeMode == ThemeMode.dark;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        '$year • $timeAgo',
        style: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }
}
