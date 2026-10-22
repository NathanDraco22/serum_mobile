import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

/// Pantalla inicial de carga (Splash) mostrada mientras se determina el estado
/// de la sesión y la vinculación de la terminal a Serum LIS.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: ColorPalette.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: ColorPalette.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                size: 48,
                color: ColorPalette.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Serum Mobile',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: ColorPalette.primary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Supervisión y Control Clínico',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorPalette.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 36),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
