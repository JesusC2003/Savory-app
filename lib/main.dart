import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_savory/UI/app.dart';
import 'package:proyecto_savory/core/config/environment.dart';
import 'package:proyecto_savory/firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  await Environment.load();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp()); // MyApp es StatefulWidget pero puede ser const en construcción
}


