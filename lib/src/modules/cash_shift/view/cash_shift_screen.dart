import 'package:flutter/material.dart';
import 'package:serum_mobile/config/app_theme.dart';

class CashShiftScreen extends StatelessWidget {
  const CashShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arqueos y Turnos de Caja'),
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
                  color: ColorPalette.secondary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.point_of_sale_outlined,
                  size: 48,
                  color: ColorPalette.secondary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Monitor de Turnos de Caja',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Supervisión en vivo de cajas abiertas por sucursal y detección de discrepancias de corte.',
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
