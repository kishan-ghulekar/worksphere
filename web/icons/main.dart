import 'package:flutter/material.dart';
import 'package:super_project/View/ClientScreens/ClientDashboard.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ClientDashboardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
