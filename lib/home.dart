import 'package:flutter/material.dart';
import 'moviehome.dart';
import 'settings.dart';
import 'Library.dart';
import 'search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  static const List<String> _appBarTitles = [
    'Video Capture',
    'Search',
    'History',
  ];

  // Build action buttons for each screen
  List<Widget> _buildActions(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ];
      case 1:
        return [
          IconButton(
            icon: const Icon(Icons.delete_rounded),
            onPressed: () {
              final searchScreen =
                  _widgetOptions[_selectedIndex] as SearchScreen;
              searchScreen.clearRecentSearches(context);
            },
          ),
        ];
      case 2:
        return [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshHistoryScreen,
          ),
        ];
      default:
        return [];
    }
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeWidget(), // Home screen widget
    const SearchScreen(),
    const LibraryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _refreshHistoryScreen() async {
    try {
      // Simulate a network call or data refresh
      await Future.delayed(const Duration(seconds: 2));

      // Here, you can trigger any state update or data reload
      // For example, reloading data from a server or refreshing the list
    } catch (e) {
      _showError('Failed to refresh history. Please try again later.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: _buildActions(context),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 25,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 25,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.library_books,
              size: 25,
            ),
            label: 'Library',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        unselectedFontSize: 16,
        selectedFontSize: 16,
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
        onTap: _onItemTapped,
      ),
    );
  }
}
