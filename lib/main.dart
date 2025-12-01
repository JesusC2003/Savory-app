import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_savory/UI/app.dart';
import 'package:proyecto_savory/core/config/environment.dart';
import 'package:proyecto_savory/firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Environment.load();
  
  Environment.verificarConfiguracion();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp()); 
}


