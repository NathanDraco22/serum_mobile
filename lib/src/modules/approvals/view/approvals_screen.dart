import 'package:flutter/material.dart';
import 'package:serum_mobile/config/app_theme.dart';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprobaciones'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorPalette.warning.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  size: 48,
                  color: ColorPalette.warning,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bandeja de Aprobaciones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aquí se listarán las órdenes retenidas por descuento especial para autorización en 1-tap.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ColorPalette.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
