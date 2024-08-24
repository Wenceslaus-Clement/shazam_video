import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import for SharedPreferences
import 'themenotifier.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MovieDetailScreen extends StatefulWidget {
  final String movieTitle;
  final String movieId;
  final String videoPath;

  const MovieDetailScreen({
    required this.movieTitle,
    required this.movieId,
    required this.videoPath,
    super.key,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Map<String, dynamic> movieDetails = {};
  Map<String, double> videoSimilarityResults = {};
  bool _isLoading = true;
  bool _isAddedToWatchlist = false;
  bool _isAnalyzingVideo = false;

  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
    _checkIfAddedToWatchlist(); // Check if the movie is already in the watchlist
    _analyzeVideoPatterns();
  }

  Future<void> _fetchMovieDetails() async {
    final String apiUrl =
        'https://api.themoviedb.org/3/movie/${widget.movieId}';
    const String apiKey = 'f6f74d3416647ac0ebd60667187fa8b8'; // TMDB API key
    const String omdbApiKey = '71448efb'; // OMDB API key

    try {
      final response = await http.get(Uri.parse('$apiUrl?api_key=$apiKey'));

      if (response.statusCode == 200) {
        setState(() {
          movieDetails = json.decode(response.body);
        });

        // Fetch additional details from OMDB
        final omdbResponse = await http.get(Uri.parse(
            'http://www.omdbapi.com/?i=${widget.movieId}&apikey=$omdbApiKey'));

        if (omdbResponse.statusCode == 200) {
          final omdbData = json.decode(omdbResponse.body);
          setState(() {
            movieDetails.addAll(omdbData);
          });
        } else {
          // Handle OMDB API error
          debugPrint('Failed to fetch OMDB data: ${omdbResponse.statusCode}');
        }
      } else {
        _showError('Failed to load movie details. Please try again later.');
      }
    } catch (e) {
      _showError('An error occurred while fetching movie details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _analyzeVideoPatterns() async {
    setState(() {
      _isAnalyzingVideo = true;
    });

    try {
      final videoFeatures = await _getVideoFeatures(widget.videoPath);
      final videoDir = await _getVideoDirectory();

      Map<String, double> results = {};

      for (File videoFile in videoDir.listSync().whereType<File>()) {
        final features = await _getVideoFeatures(videoFile.path);
        final similarity = _getSimilarity(videoFeatures, features);
        results[videoFile.path] = similarity;
      }

      setState(() {
        videoSimilarityResults = results;
      });
    } catch (e) {
      _showError('An error occurred while analyzing video patterns: $e');
    } finally {
      setState(() {
        _isAnalyzingVideo = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getVideoFeatures(String videoPath) async {
    // Placeholder for video features extraction using OpenCV or TensorFlow models
    return <String, dynamic>{};
  }

  Future<Directory> _getVideoDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return Directory('${directory.path}/video_tests');
  }

  double _getSimilarity(
      Map<String, dynamic> features1, Map<String, dynamic> features2) {
    // Placeholder for calculating similarity between two sets of features
    return 0.0;
  }

  void _checkIfAddedToWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final watchlist = prefs.getStringList('watchlist') ?? [];
    if (watchlist.contains(widget.movieId)) {
      setState(() {
        _isAddedToWatchlist = true;
      });
    }
  }

  void _addToWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final watchlist = prefs.getStringList('watchlist') ?? [];
    if (!watchlist.contains(widget.movieId)) {
      watchlist.add(widget.movieId);
      await prefs.setStringList('watchlist', watchlist);

      setState(() {
        _isAddedToWatchlist = true;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to Watchlist')),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        context.watch<ThemeNotifier>().themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movieTitle),
        backgroundColor: isDarkMode ? Colors.black : Colors.blue,
        actions: [
          IconButton(
            icon: Icon(
              _isAddedToWatchlist ? Icons.favorite : Icons.favorite_border,
              color: _isAddedToWatchlist ? Colors.red : Colors.white,
            ),
            onPressed: _isAddedToWatchlist ? null : _addToWatchlist,
          ),
          if (_isAddedToWatchlist)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Added to Wishlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (movieDetails.isNotEmpty)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://image.tmdb.org/t/p/w500${movieDetails['poster_path']}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    widget.movieTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${movieDetails['runtime']} mins | ${movieDetails['release_date'].substring(0, 4)} | ${movieDetails['vote_average']} Rating',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Add functionality to watch the movie
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDarkMode ? Colors.blue : Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 32.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Watch Now',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: _isAddedToWatchlist ? null : _addToWatchlist,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 32.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          _isAddedToWatchlist ? 'Added' : 'Add to Watchlist',
                          style: TextStyle(
                            color: _isAddedToWatchlist
                                ? Colors.grey
                                : isDarkMode
                                    ? Colors.white
                                    : Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isAnalyzingVideo)
                    const Center(child: CircularProgressIndicator()),
                  if (videoSimilarityResults.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: videoSimilarityResults.entries.map((entry) {
                        return Text(
                          'Similarity with ${entry.key}: ${entry.value.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
    );
  }
}
