import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themenotifier.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(ThemeMode.light),
      child: const ShazamVideo(),
    );
  }
}

class ShazamVideo extends StatefulWidget {
  const ShazamVideo({super.key});

  // Removed the public method that exposes the private state
  @override
  State<ShazamVideo> createState() => _ShazamVideoState();
}

class _ShazamVideoState extends State<ShazamVideo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: context.watch<ThemeNotifier>().themeMode,
      debugShowCheckedModeBanner: false,
      title: "Video Capture",
      home: const HomeScreen(),
    );
  }
}
