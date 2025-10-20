import 'package:flutter/material.dart';
import 'package:proyecto_savory/UI/auth/login_page.dart';
import 'package:proyecto_savory/UI/auth/register_page.dart';
import 'package:proyecto_savory/UI/home/Homepage.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Savory',

      initialRoute: '/login', // Pantalla inicial
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const Homepage(),
      },
    );
  }
}
