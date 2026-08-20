import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart'; // Import the new splash screen

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const ArthoGuardApp());
}

class ArthoGuardApp extends StatelessWidget {
  const ArthoGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArthoGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F8FF), // Updated to a beautiful icy blue-white
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E6FF3)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(), // Starts the app at the splash screen
    );
  }
}