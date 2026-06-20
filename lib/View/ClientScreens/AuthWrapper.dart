import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:super_project/View/ClientScreens/ClientDashboard.dart';
import 'package:super_project/View/ClientScreens/loginScreen.dart';
import 'package:super_project/View/FreelancerDashboard/freelancerDashboard.dart';

class Authwrapper extends StatelessWidget {
  const Authwrapper({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return SplashRoleChecker();
    }
    return LoginScreen();
  }
}

class SplashRoleChecker extends StatefulWidget {
  const SplashRoleChecker({super.key});

  @override
  State<SplashRoleChecker> createState() => _SplashRoleChecker();
}

class _SplashRoleChecker extends State<SplashRoleChecker> {
  @override
  void initState() {
    super.initState();
    checkRole();
  }

  Future<void> checkRole() async{

    User user = FirebaseAuth.instance.currentUser!;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      throw Exception("User document not found");
    } 

    String role = doc.get('role') as String; 

    if (!mounted) return;

    if (role == 'client') {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ClientDashboardPage(),
        ),
      );

    } else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Freelancerdashboard(),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
