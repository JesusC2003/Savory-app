import 'package:flutter/material.dart';
import 'package:proyecto_savory/UI/home/Homepage.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: Homepage()
    );
  }
}