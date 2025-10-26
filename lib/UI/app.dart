import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      // En lugar de initialRoute, usamos home con AuthWrapper para persistencia
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const Homepage(),
      },
    );
  }
}

// Widget que verifica el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras se verifica la autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF47A72F),
              ),
            ),
          );
        }

        // Si hay un usuario autenticado (mantiene sesión)
        if (snapshot.hasData) {
          return const Homepage();
        }

        // Si no hay usuario autenticado
        return const LoginPage();
      },
    );
  }
}