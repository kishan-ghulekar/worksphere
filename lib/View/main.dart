import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:super_project/View/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const WorkSphereApp());
}

class WorkSphereApp extends StatelessWidget {
  const WorkSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkSphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF5A4BCC),
        scaffoldBackgroundColor: const Color(0xFFF6F5F8),
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A4BCC),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF5A4BCC),
        scaffoldBackgroundColor: const Color(0xFF110F23),
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A4BCC),
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
