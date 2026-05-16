import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shree/models/user_model.dart';
import 'package:shree/screens/auth/login_screen.dart';
import 'package:shree/screens/home/home_screen.dart';
import 'package:shree/screens/navigation/main_navigation.dart';
import 'package:shree/services/auth_service.dart';
import 'package:shree/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 3), _checkLogin);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkLogin() async {
    if (!mounted) return;

    final profile = await AuthService.currentUserProfile();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => _destinationFor(profile)),
    );
  }

  Widget _destinationFor(AppUser? profile) {
    if (profile == null) {
      return const LoginScreen();
    }

    if (profile.role.toLowerCase() == 'admin') {
      return const HomeScreen(isAdmin: true);
    }

    return const MainNavigation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.night,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x264C8A79), Color(0x0006110F)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x22D3AA64), Color(0x0006110F)],
                ),
              ),
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 900),
              tween: Tween(begin: 0.92, end: 1),
              curve: Curves.easeOutBack,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: const Color(0x26F2D7A3)),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF132B26), Color(0xFF0E1E1B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x45000000),
                      blurRadius: 40,
                      offset: Offset(0, 22),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_bar_rounded,
                      size: 66,
                      color: AppTheme.secondaryColor,
                    ),
                    SizedBox(height: 18),
                    Text(
                      'SHREE',
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontSize: 36,
                        letterSpacing: 7,
                        fontWeight: FontWeight.w400,
                        fontFamily: AppTheme.serifFontFamily,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'PERFUME',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 17,
                        letterSpacing: 9,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 28),
                    Text(
                      'RICHER. CLEANER. MORE PROFESSIONAL.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.mutedTextColor,
                        fontSize: 13,
                        letterSpacing: 1.8,
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
