import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de colores clínicos para Serum Mobile basada en AppColor.md y SUPER_PROMPT.md.
class ColorPalette {
  ColorPalette._();

  // Superficies y Fondos
  static const Color surface = Color(0xFFF7F9FF);
  static const Color surfaceDim = Color(0xFFD7DAE0);
  static const Color surfaceBright = Color(0xFFF7F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F4FA);
  static const Color surfaceContainer = Color(0xFFEBEEF4);
  static const Color surfaceContainerHigh = Color(0xFFE5E8EE);
  static const Color surfaceContainerHighest = Color(0xFFDFE3E8);
  static const Color onSurface = Color(0xFF181C20);
  static const Color onSurfaceVariant = Color(0xFF3F4850);
  static const Color inverseSurface = Color(0xFF2D3135);
  static const Color inverseOnSurface = Color(0xFFEEF1F7);

  // Bordes y Delineados
  static const Color outline = Color(0xFF707881);
  static const Color outlineVariant = Color(0xFFBFC7D2);

  // Primario (Teal Clínico)
  static const Color primary = Color(0xFF006194);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF007BB9);
  static const Color onPrimaryContainer = Color(0xFFFDFCFF);
  static const Color inversePrimary = Color(0xFF93CCFF);

  // Secundario y Terciario
  static const Color secondary = Color(0xFF505F76);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD0E1FB);
  static const Color onSecondaryContainer = Color(0xFF54647A);
  static const Color tertiary = Color(0xFF894D00);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Semáforo y Alertas Médicas
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  
  static const Color success = Color(0xFF1E8E3E);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFDCF8DF);

  static const Color warning = Color(0xFFD97706);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color blockedBadge = Color(0xFFD97706);
}

/// Temas globales de Serum Mobile.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: ColorPalette.primary,
      onPrimary: ColorPalette.onPrimary,
      primaryContainer: ColorPalette.primaryContainer,
      onPrimaryContainer: ColorPalette.onPrimaryContainer,
      secondary: ColorPalette.secondary,
      onSecondary: ColorPalette.onSecondary,
      secondaryContainer: ColorPalette.secondaryContainer,
      onSecondaryContainer: ColorPalette.onSecondaryContainer,
      tertiary: ColorPalette.tertiary,
      onTertiary: ColorPalette.onTertiary,
      error: ColorPalette.error,
      onError: ColorPalette.onError,
      errorContainer: ColorPalette.errorContainer,
      onErrorContainer: ColorPalette.onErrorContainer,
      surface: ColorPalette.surface,
      onSurface: ColorPalette.onSurface,
      onSurfaceVariant: ColorPalette.onSurfaceVariant,
      outline: ColorPalette.outline,
      outlineVariant: ColorPalette.outlineVariant,
      inverseSurface: ColorPalette.inverseSurface,
      onInverseSurface: ColorPalette.inverseOnSurface,
      inversePrimary: ColorPalette.inversePrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ColorPalette.surface,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: ColorPalette.surface,
        foregroundColor: ColorPalette.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ColorPalette.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ColorPalette.surfaceContainerLowest,
        elevation: 3,
        indicatorColor: ColorPalette.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ColorPalette.primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ColorPalette.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: ColorPalette.primary, size: 24);
          }
          return const IconThemeData(color: ColorPalette.onSurfaceVariant, size: 24);
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: ColorPalette.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ColorPalette.outlineVariant, width: 0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: ColorPalette.primary,
          foregroundColor: ColorPalette.onPrimary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ColorPalette.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: ColorPalette.inversePrimary,
      surface: const Color(0xFF13171A),
      onSurface: const Color(0xFFE2E6EC),
      outlineVariant: const Color(0xFF38434D),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1A1F24),
        indicatorColor: colorScheme.primary.withAlpha(50),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E242A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 0.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: const Color(0xFF003353),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
