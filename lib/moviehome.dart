import 'package:flutter/material.dart';
import 'themenotifier.dart';
import 'package:provider/provider.dart';
import 'moviedetail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  bool _isLoading = false; // To track loading state
  List<Map<String, dynamic>> _searchResults = []; // To store search results

  // API details
  final String _tmdbApiUrl = 'https://api.themoviedb.org/3/discover/movie';
  final String _tmdbApiKey = 'f6f74d3416647ac0ebd60667187fa8b8'; // TMDB API key
  final String _tmdbImageUrl =
      'https://image.tmdb.org/t/p/w500/'; // TMDB Image base URL

  @override
  void initState() {
    super.initState();
    _fetchMovies(); // Fetch movies when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        context.watch<ThemeNotifier>().themeMode == ThemeMode.dark;

    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  children: _searchResults.isEmpty
                      ? [const Center(child: Text("No movies found"))]
                      : _searchResults.map((movie) {
                          return GestureDetector(
                            onTap: () => _navigateToMovieDetail(context,
                                movie['title'], movie['id'].toString()),
                            child: MovieCard(
                              title: movie['title'],
                              imageUrl: '$_tmdbImageUrl${movie['poster_path']}',
                            ),
                          );
                        }).toList(),
                ),
        ),
        Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                // Start the process of capturing the snippet
                await captureAndSearchSnippet();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: isDarkMode
                    ? Colors.green
                    : const Color.fromARGB(255, 21, 95, 23),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: Text(
                'Tap to Capture',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            )),
      ],
    );
  }

  void _fetchMovies() async {
    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    // API call to discover popular movies using TMDB
    final tmdbResponse = await http.get(
      Uri.parse('$_tmdbApiUrl?api_key=$_tmdbApiKey&sort_by=popularity.desc'),
    );

    if (tmdbResponse.statusCode == 200) {
      final data = json.decode(tmdbResponse.body);
      final results = data['results'] as List<dynamic>;

      // Update search results with TMDB data
      setState(() {
        _searchResults = results
            .map((movie) => {
                  'title': movie['title'],
                  'id': movie['id'],
                  'poster_path': movie['poster_path'], // Add poster path
                })
            .toList();
      });
    } else {
      setState(() {
        _searchResults = [
          {'title': 'Error fetching TMDB results', 'id': 0}
        ];
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToMovieDetail(
      BuildContext context, String title, String movieId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(
          movieTitle: title,
          movieId: movieId,
          videoPath: '',
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const MovieCard({required this.title, required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        context.watch<ThemeNotifier>().themeMode == ThemeMode.dark;
    return Card(
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
