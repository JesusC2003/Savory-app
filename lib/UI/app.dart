import 'package:flutter/material.dart';
import 'package:proyecto_savory/UI/auth/login_page.dart';
import 'package:proyecto_savory/UI/auth/register_page.dart';
import 'package:proyecto_savory/UI/auth/forgot_password_page.dart';
import 'package:proyecto_savory/UI/home/Homepage.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Savory',
      theme: ThemeData(
        primaryColor: const Color(0xFF47A72F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF47A72F),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const Homepage(),
      },
    );
  }
}