import 'package:flutter/material.dart';
import 'package:serum_mobile/config/app_theme.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes y Resultados'),
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
                  color: ColorPalette.primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  size: 48,
                  color: ColorPalette.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Visor Clínico de Órdenes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Buscador de pacientes, folio y visualización de flags médicos analíticos.',
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
