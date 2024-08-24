import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';
import 'themenotifier.dart';
import 'package:provider/provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _newMovieRecognition = false;
  bool _appUpdates = false;
  bool _specialOffers = false;
  bool _isSaving = false; // Loading state for save button

  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = false;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _newMovieRecognition = prefs.getBool('newMovieRecognition') ?? false;
        _appUpdates = prefs.getBool('appUpdates') ?? false;
        _specialOffers = prefs.getBool('specialOffers') ?? false;
      });
    } catch (e) {
      _showError('Failed to load settings. Please try again later.');
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true; // Start loading indicator
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('newMovieRecognition', _newMovieRecognition);
      await prefs.setBool('appUpdates', _appUpdates);
      await prefs.setBool('specialOffers', _specialOffers);

      _showMessage('Settings saved!');
    } catch (e) {
      _showError('Failed to save settings. Please try again later.');
    } finally {
      setState(() {
        _isSaving = false; // Stop loading indicator
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor:
            _isDarkMode ? const Color.fromARGB(255, 21, 95, 23) : Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        context.watch<ThemeNotifier>().themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Preferences',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).pop(
              MaterialPageRoute(
                builder: (context) {
                  return const SettingsScreen();
                },
              ),
            );
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSwitchTile(
              'New movie recognition',
              'Get notified when we add new movies to our database',
              _newMovieRecognition,
              (value) {
                setState(() {
                  _newMovieRecognition = value;
                });
              },
            ),
            Divider(
              thickness: 2,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            _buildSwitchTile(
              'App updates',
              'Stay in the loop with the latest features and improvements',
              _appUpdates,
              (value) {
                setState(() {
                  _appUpdates = value;
                });
              },
            ),
            Divider(
              thickness: 2,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            _buildSwitchTile(
              'Special offers',
              'Be the first to know about our exclusive deals and promotions',
              _specialOffers,
              (value) {
                setState(() {
                  _specialOffers = value;
                });
              },
            ),
            const Spacer(),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () {
                      _saveSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 0),
                      backgroundColor: isDarkMode
                          ? Colors.green
                          : const Color.fromARGB(255, 21, 95, 23),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ), // Full width button
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
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    final isDarkMode =
        context.watch<ThemeNotifier>().themeMode == ThemeMode.dark;
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.green,
    );
  }
}
