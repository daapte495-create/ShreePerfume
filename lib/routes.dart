import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_home.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const adminLogin = '/admin/login';
  static const adminRegister = '/admin/register';
  static const adminForgotPassword = '/admin/forgot-password';
  static const adminHome = '/admin/home';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    home: (context) => const HomeScreen(),
    adminLogin: (context) => const LoginScreen(isAdmin: true),
    adminRegister: (context) => const RegisterScreen(isAdmin: true),
    adminForgotPassword: (context) => const ForgotPasswordScreen(isAdmin: true),
    adminHome: (context) => const AdminHome(),
  };
}
