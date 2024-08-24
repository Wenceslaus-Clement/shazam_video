import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'themenotifier.dart';
import 'home.dart';
import 'notification.dart';
import 'library.dart';
// Import the HistoryScreen

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    isDarkMode = false;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    themeNotifier.toggleTheme(isDarkMode);
  }

  Future<void> _saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Settings saved!',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor:
            isDarkMode ? const Color.fromARGB(255, 21, 95, 23) : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Video Capture',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(
              isDarkMode ? 'Dark theme' : 'Light theme',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: _toggleDarkMode,
              activeColor: Colors.green,
            ),
          ),
          Divider(
            thickness: 2,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          ListTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            title: Text(
              'Notification preferences',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Manage when to receive notifications',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? Colors.green
                    : const Color.fromARGB(255, 21, 95, 23),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const NotificationSettingsScreen(); // Assuming this screen exists
                    },
                  ),
                );
              },
              child: Text(
                'Manage',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.white,
                ),
              ),
            ),
          ),
          Divider(
            thickness: 2,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          ListTile(
            title: Text(
              'Audio recognition',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Adjust sensitivity for better results',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? Colors.green
                    : const Color.fromARGB(255, 21, 95, 23),
              ),
              onPressed: () {},
              child: Text(
                'Adjust',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.white,
                ),
              ),
            ),
          ),
          Divider(
            thickness: 2,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          ListTile(
            title: Text(
              'Search history',
              style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'View and manage your search history',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? Colors.green
                    : const Color.fromARGB(255, 21, 95, 23),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const LibraryScreen(); // Navigate to HistoryScreen
                    },
                  ),
                );
              },
              child: Text(
                'View',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: const Size(double.infinity, 0),
              backgroundColor: isDarkMode
                  ? Colors.green
                  : const Color.fromARGB(255, 21, 95, 23),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Save changes',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
