import 'package:flutter/material.dart';
import 'constants.dart';
import 'text_styles.dart';
import 'custom_nav_style.dart';

MaterialColor createMaterialColor(Color color) {
  final strengths = <double>[.05];
  final swatch = <int, Color>{};
  final double r = ((color.toARGB32() >> 16) & 0xFF).toDouble();
  final double g = ((color.toARGB32() >> 8) & 0xFF).toDouble();
  final double b = (color.toARGB32() & 0xFF).toDouble();

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (final strength in strengths) {
    final ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      (r + ((ds < 0 ? r : (255 - r)) * ds)).round(),
      (g + ((ds < 0 ? g : (255 - g)) * ds)).round(),
      (b + ((ds < 0 ? b : (255 - b)) * ds)).round(),
      1.0,
    );
  }

  return MaterialColor(color.toARGB32(), swatch);
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true, // Activar Material 3 para mejores animaciones por defecto
  scaffoldBackgroundColor: AppConstants.backgroundColor,
  primaryColor: AppConstants.primaryColor,
  primarySwatch: createMaterialColor(AppConstants.primaryColor),
  
  // Esquema de colores oscuro y elegante
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppConstants.primaryColor,
    brightness: Brightness.dark,
    primary: AppConstants.primaryColor,
    secondary: AppConstants.secondaryColor,
    surface: AppConstants.surfaceColor,
    background: AppConstants.backgroundColor, // deprecated en nuevas versiones pero útil
    error: AppConstants.errorColor,
    onPrimary: AppConstants.textLight,
    onSecondary: AppConstants.textLight,
    onSurface: AppConstants.textLight,
    onBackground: AppConstants.textLight,
  ),

  extensions: <ThemeExtension<dynamic>>[
    const CustomNavStyle(
      backgroundColor: AppConstants.surfaceColor,
      selectedColor: AppConstants.textLight,
      unselectedColor: AppConstants.lightGrey,
      labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    ),
  ],
  fontFamily: 'Montserrat',
  textTheme: TextTheme(
    // Títulos grandes y audaces
    headlineLarge: AppTextStyles.heading.copyWith(fontFamily: 'Montserrat', fontWeight: FontWeight.w800, letterSpacing: -0.5),
    headlineMedium: AppTextStyles.subheading.copyWith(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
    
    // Cuerpo de texto legible
    bodyLarge: AppTextStyles.musicTitle.copyWith(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
    bodyMedium: AppTextStyles.musicSubtitle.copyWith(fontFamily: 'Montserrat', fontWeight: FontWeight.w400, height: 1.5),
    
    // Etiquetas pequeñas estilo "Premium" (caps + tracking)
    labelMedium: AppTextStyles.navLabel.copyWith(fontFamily: 'Montserrat', letterSpacing: 1.0, fontWeight: FontWeight.bold),
    labelSmall: const TextStyle(fontFamily: 'Montserrat', fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700, color: Colors.grey),
  ),
  
  // Botones modernos y redondeados
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: AppConstants.textLight,
      elevation: 8,
      shadowColor: AppConstants.primaryColor.withAlpha(100),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
    ),
  ),

  // Cards estilo "Glass" o muy oscuras
  cardTheme: CardThemeData(
    color: AppConstants.surfaceColor,
    elevation: 0, // Sin sombra default, usamos custom shadows
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24), // Muy redondeado
      side: BorderSide(color: Colors.white.withAlpha(15), width: 1), // Borde sutil
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
  ),
  
  // Inputs estilo iOS/Moderno
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1A1A1A),
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.white.withAlpha(10))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2)),
    hintStyle: TextStyle(color: Colors.grey[600]),
  ),

  dividerTheme: const DividerThemeData(
    thickness: 1,
    space: 1,
    color: AppConstants.darkGrey,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppConstants.primaryColor,
    foregroundColor: AppConstants.textLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppConstants.errorColor,
    contentTextStyle: const TextStyle(
      color: AppConstants.textLight,
      fontSize: 14,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppConstants.lightGradient,
    selectedColor: AppConstants.primaryColor.withAlpha((0.2 * 255).round()),
    secondarySelectedColor: AppConstants.primaryColor,
    disabledColor: AppConstants.lightGrey,
    labelStyle: const TextStyle(color: AppConstants.textLight),
    secondaryLabelStyle: const TextStyle(color: AppConstants.textLight),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppConstants.primaryColor,
    linearTrackColor: AppConstants.lightGrey,
  ),
);
