import 'dart:async';

import 'package:flutter/material.dart';

import 'OnboardingScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _simulateLoading();
  }

  void _simulateLoading() {
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _loadingProgress++;
          if (_loadingProgress >= 3) {
            timer.cancel();
            // Navigate to onboarding after 2 seconds
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                );
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFF6F5F8) : const Color(0xFF110F23);
    final subtitleColor =
        isDark
            ? const Color(0xFFF6F5F8).withOpacity(0.7)
            : const Color(0xFF110F23).withOpacity(0.7);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDark
                    ? [const Color(0xFF110F23), const Color(0xFF1A1635)]
                    : [const Color(0xFFF6F5F8), const Color(0xFFE8E6F0)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with animation
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF5A4BCC,
                                      ).withOpacity(0.4),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(70),
                                  child: Image.asset(
                                    'assets/AppLogo1.png',
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback if image not found
                                      return Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF5A4BCC),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.hub_rounded,
                                          size: 70,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),

                      // App name with animation
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                'WorkSphere',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                  letterSpacing: -1,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tagline with animation
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value * 1.5),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                'Where Talent Meets Opportunity',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: subtitleColor,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Subtagline
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value * 2),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                'Your Gateway to Freelance Success',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: subtitleColor.withOpacity(0.7),
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Loading text
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Loading your workspace...',
                          style: TextStyle(
                            fontSize: 12,
                            color: subtitleColor.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Progress indicator dots
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDot(_loadingProgress >= 1),
                            const SizedBox(width: 12),
                            _buildDot(_loadingProgress >= 2),
                            const SizedBox(width: 12),
                            _buildDot(_loadingProgress >= 3),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 32 : 10,
      height: 10,
      decoration: BoxDecoration(
        color:
            isActive
                ? const Color(0xFF5A4BCC)
                : isDark
                ? const Color(0xFF5A4BCC).withOpacity(0.3)
                : const Color(0xFF5A4BCC).withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
