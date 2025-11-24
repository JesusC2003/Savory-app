import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_savory/UI/auth/login_page.dart';
import 'package:proyecto_savory/UI/auth/register_page.dart';
import 'package:proyecto_savory/UI/auth/forgot_password_page.dart';
import 'package:proyecto_savory/UI/home/Homepage.dart';

// Provider simple para tema global
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeProvider,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Savory',
          theme: _getTheme(false),
          darkTheme: _getTheme(true),
          themeMode: _themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: AuthWrapper(themeProvider: _themeProvider),
          routes: {
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/forgot-password': (context) => const ForgotPasswordPage(),
            '/home': (context) => const Homepage(),
          },
        );
      },
    );
  }

  ThemeData _getTheme(bool isDark) {
    return ThemeData(
      primaryColor: const Color(0xFF47A72F),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF47A72F),
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
  }
}

// Widget que verifica el estado de autenticación
class AuthWrapper extends StatelessWidget {
  final ThemeProvider themeProvider;

  const AuthWrapper({super.key, required this.themeProvider});

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
          return Homepage(themeProvider: themeProvider);
        }

        // Si no hay usuario autenticado
        return const LoginPage();
      },
    );
  }
}