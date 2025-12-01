import 'package:flutter/material.dart';

class DespensaConstants {
  // Colores
  static const Color verdeSavory = Color(0xFF47A72F);
  static const Color azulInfo = Colors.blue;
  static const Color naranjaWarning = Colors.orange;
  static const Color rojoError = Colors.redAccent;

  // Unidades de medida
  static const List<Map<String, String>> unidades = [
    {'value': 'unidades', 'label': 'Unidades'},
    {'value': 'gramos', 'label': 'Gramos (gr)'},
    {'value': 'kilogramos', 'label': 'Kilogramos (kg)'},
    {'value': 'litros', 'label': 'Litros (L)'},
    {'value': 'mililitros', 'label': 'Mililitros (ml)'},
    {'value': 'paquetes', 'label': 'Paquetes'},
    {'value': 'latas', 'label': 'Latas'},
  ];

  // Abreviaciones de unidades
  static String getUnitAbbreviation(String unidad) {
    switch (unidad) {
      case 'gramos':
        return 'gr';
      case 'kilogramos':
        return 'kg';
      case 'litros':
        return 'L';
      case 'mililitros':
        return 'ml';
      default:
        return unidad;
    }
  }

  // Textos
  static const String tituloAgregarManual = 'Agregar ingrediente';
  static const String tituloIngredientesDetectados = 'Ingredientes detectados';
  static const String mensajeDespensaVacia = 'Tu despensa está vacía';
  static const String mensajeAgregarParaComenzar = 'Agrega ingredientes para comenzar';
  static const String mensajeProcesandoImagen = '📸 Procesando imagen...';
  static const String mensajeAgregandoIngredientes = 'Agregando ingredientes...';

  // Íconos
  static const IconData iconoDespensa = Icons.kitchen_outlined;
  static const IconData iconoAgregar = Icons.add;
  static const IconData iconoCamara = Icons.camera_alt;
  static const IconData iconoGaleria = Icons.photo_library;
  static const IconData iconoEditar = Icons.edit;
}