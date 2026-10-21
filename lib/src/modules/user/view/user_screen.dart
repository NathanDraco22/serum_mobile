import 'package:flutter/material.dart';
import 'package:serum_mobile/config/app_theme.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de Usuarios'),
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
                  color: ColorPalette.tertiary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.manage_accounts_outlined,
                  size: 48,
                  color: ColorPalette.tertiary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Directorio de Personal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Consulta de colaboradores y formulario de alta para nuevos usuarios y roles.',
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
