import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'themenotifier.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();

  Future<void> clearRecentSearches(BuildContext context) async {
    final state = context.findAncestorStateOfType<SearchScreenState>();
    if (state != null) {
      await state.clearRecentSearches(context);
    }
  }
}

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> recentSearches = [];
  List<String> suggestions = [];
  bool _isLoading = true;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadThemeMode();
      _loadRecentSearches();
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      suggestions = _getSuggestions(_searchController.text);
    });
  }

  Future<void> _loadThemeMode() async {
    final themeNotifier = context.read<ThemeNotifier>();
    setState(() {
      _isDarkMode = themeNotifier.themeMode == ThemeMode.dark;
    });
  }

  List<String> _getSuggestions(String query) {
    if (query.isEmpty) return [];

    final matches = <String>[];
    matches.addAll(recentSearches);
    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        recentSearches = prefs.getStringList('recentSearches') ?? [];
        _isLoading = false;
      });
    } catch (e) {
      _showErrorDialog('Failed to load recent searches');
    }
  }

  Future<void> _saveRecentSearch(String search) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!recentSearches.contains(search)) {
        setState(() {
          recentSearches.insert(0, search);
          if (recentSearches.length > 5) {
            recentSearches.removeLast();
          }
        });
        await prefs.setStringList('recentSearches', recentSearches);
      }
    } catch (e) {
      _showErrorDialog('Failed to save recent search');
    }
  }

  Future<void> clearRecentSearches(BuildContext context) async {
    final confirm = await _showConfirmationDialog('Clear recent searches?');
    if (!confirm) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('recentSearches');
      setState(() {
        recentSearches.clear();
      });
    } catch (e) {
      _showErrorDialog('Failed to clear recent searches');
    }
  }

  Future<bool> _showConfirmationDialog(String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('OK'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  key: const Key('searchTextField'),
                  controller: _searchController,
                  cursorColor: _isDarkMode ? Colors.white : Colors.black54,
                  decoration: InputDecoration(
                    hintText: 'Movie, actor, or line',
                    hintStyle: TextStyle(
                      color: _isDarkMode ? Colors.white70 : Colors.black45,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    prefixIconColor:
                        _isDarkMode ? Colors.white70 : Colors.black45,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: _isDarkMode
                        ? Colors.black54
                        : const Color.fromARGB(255, 207, 206, 206),
                  ),
                  onSubmitted: (String search) {
                    if (search.isNotEmpty) {
                      _saveRecentSearch(search);
                      _searchController.clear();
                    }
                  },
                ),
                const SizedBox(height: 20),
                if (recentSearches.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Searches',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode
                              ? Colors.white70
                              : Colors.black.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: recentSearches.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(recentSearches[index]),
                            onTap: () {
                              setState(() {
                                _searchController.text = recentSearches[index];
                                suggestions =
                                    _getSuggestions(recentSearches[index]);
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                if (suggestions.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(suggestions[index]),
                          onTap: () {
                            setState(() {
                              _searchController.text = suggestions[index];
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}
