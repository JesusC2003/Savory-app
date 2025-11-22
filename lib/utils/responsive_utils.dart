// lib/utils/responsive_utils.dart

import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Porcentaje del ancho de pantalla
  static double wp(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }

  // Porcentaje de la altura de pantalla
  static double hp(BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100);
  }

  // Tamaño de fuente responsivo
  static double sp(BuildContext context, double size) {
    final width = screenWidth(context);
    if (width < 360) {
      return size * 0.85; // Pantallas pequeñas
    } else if (width < 400) {
      return size * 0.95; // Pantallas medianas
    } else if (width > 500) {
      return size * 1.1; // Tablets
    }
    return size; // Normal
  }

  // Detectar tipo de dispositivo
  static bool isSmallScreen(BuildContext context) {
    return screenWidth(context) < 360;
  }

  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= 600;
  }

  static bool isLargeScreen(BuildContext context) {
    return screenWidth(context) >= 900;
  }

  // Padding responsivo
  static EdgeInsets pagePadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.all(12);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    }
    return const EdgeInsets.all(16);
  }

  // Espaciado vertical responsivo
  static SizedBox verticalSpace(BuildContext context, double percentage) {
    return SizedBox(height: hp(context, percentage));
  }

  // Espaciado horizontal responsivo
  static SizedBox horizontalSpace(BuildContext context, double percentage) {
    return SizedBox(width: wp(context, percentage));
  }

  // Tamaño de íconos responsivo
  static double iconSize(BuildContext context, {double baseSize = 24}) {
    if (isSmallScreen(context)) {
      return baseSize * 0.85;
    } else if (isTablet(context)) {
      return baseSize * 1.2;
    }
    return baseSize;
  }

  // Altura de botones responsiva
  static double buttonHeight(BuildContext context) {
    if (isSmallScreen(context)) {
      return 45;
    } else if (isTablet(context)) {
      return 60;
    }
    return 50;
  }

  // Radio de bordes responsivo
  static double borderRadius(BuildContext context, {double base = 12}) {
    if (isSmallScreen(context)) {
      return base * 0.8;
    } else if (isTablet(context)) {
      return base * 1.3;
    }
    return base;
  }
}