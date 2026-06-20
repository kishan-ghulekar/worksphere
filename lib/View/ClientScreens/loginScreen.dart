import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:super_project/View/ClientScreens/ClientDashboard.dart';
import 'package:super_project/View/ClientScreens/ResetPasswordPage.dart';
import 'package:super_project/View/ClientScreens/roleSelectionPage.dart';
// import 'package:super_project/View/ClientScreens/ChoosePathPage.dart';
import 'package:super_project/View/FreelancerDashboard/freelancerDashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Verify email + password against Firebase Auth
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;

      // Step 2: Look up this user's saved role in Firestore
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!mounted) return;

      // Guard: profile doc might be missing (e.g. signup partially failed)
      if (!doc.exists || doc.data() == null || doc.data()!['role'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No profile found for this account. Please sign up again or contact support.",
            ),
          ),
        );
        return;
      }

      final role = (doc.data()!['role'] as String).trim().toLowerCase();

      // Step 3: Route based on role
      if (role == 'client') {
        Navigator.pushReplacement(
          context,
          // ignore: inference_failure_on_instance_creation
          MaterialPageRoute(builder: (_) => ClientDashboardPage()),
        );
      } else if (role == 'freelancer') {
        Navigator.pushReplacement(
          context,
          // ignore: inference_failure_on_instance_creation
          MaterialPageRoute(builder: (_) => Freelancerdashboard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unrecognized role: '$role'")),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No account found with that email.";
          break;
        case 'wrong-password':
          message = "Incorrect password.";
          break;
        case 'invalid-email':
          message = "That email address looks invalid.";
          break;
        case 'invalid-credential':
          message = "Email or password is incorrect.";
          break;
        case 'too-many-requests':
          message = "Too many attempts. Please try again later.";
          break;
        case 'user-disabled':
          message = "This account has been disabled.";
          break;
        default:
          message = e.message ?? "Login failed. Please try again.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset("assets/AppLogo1.png", height: 200, width: 150),
                const Text(
                  'Login to WorkSphere',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 48),

                // Email or Username field
                const Text(
                  'Email or Username',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email or username',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Colors.grey,
                    ),
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Password field
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      // ignore: inference_failure_on_instance_creation
                      MaterialPageRoute(
                        builder: (context) {
                          return ResetPasswordPage();
                        },
                      ),
                    );
                  },
                  child: const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8B5FF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text("Login"),
                ),
                const SizedBox(height: 16),

                // Forgot Password and Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          // ignore: inference_failure_on_instance_creation
                          MaterialPageRoute(
                            builder: (context) {
                              return ResetPasswordPage();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'Password?',
                        style: TextStyle(
                          color: Color(0xFFB8B5FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          // ignore: inference_failure_on_instance_creation
                          MaterialPageRoute(
                            builder: (context) {
                              return ChoosePathPage();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFFB8B5FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}