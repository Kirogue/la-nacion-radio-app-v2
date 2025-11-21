import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'La Nacion';
  static const String baseUrl = 'https://maroon-ibis-412710.hostingersite.com/wp-json/api/';
  static const String logoPath = 'assets/images/logo.png';
  static const String youtubeChannel = 'https://www.youtube.com/@lanacionradio';
  static const bool useAlternativeVersion = true;

  // Animaciones
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Colores Base - Paleta "Ferrari Dark"
  static const Color primaryColor = Color(0xFF294D9D); // Azul La Nación (Intocable)
  static const Color secondaryColor = Color(0xFF1A469C);
  
  // Fondo Ultra Dark para contraste premium
  static const Color backgroundColor = Color(0xFF050505); // Negro casi puro
  static const Color surfaceColor = Color(0xFF121212); // Gris carbón para tarjetas
  
  // Gradientes sutiles para dar profundidad
  static const Color lightGradient = Color(0xFF1E1E1E);
  static const Color darkGradient = Color(0xFF0A0A0A);
  static const Color blueGradient = Color(0xFF294D9D); // Usamos el primario como base de gradiente


  // Colores adicionales
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF333333);
}
