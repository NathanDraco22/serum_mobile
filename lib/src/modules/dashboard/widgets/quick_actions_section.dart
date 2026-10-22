import 'package:flutter/material.dart';
import 'package:serum_mobile/config/app_theme.dart';

/// Sección de accesos directos rápidos del panel de control de Serum Mobile.
class QuickActionsSection extends StatelessWidget {
  final VoidCallback onReportsTap;
  final VoidCallback onOrdersTap;
  final VoidCallback onShiftsTap;

  const QuickActionsSection({
    super.key,
    required this.onReportsTap,
    required this.onOrdersTap,
    required this.onShiftsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Acciones Rápidas',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onReportsTap,
          icon: const Icon(Icons.insights_rounded, size: 20),
          label: const Text('Ver Reportes y Analítica Ejecutiva'),
          style: FilledButton.styleFrom(
            backgroundColor: ColorPalette.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onOrdersTap,
                icon: const Icon(Icons.search_rounded, size: 20),
                label: const Text('Buscar Órdenes'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onShiftsTap,
                icon: const Icon(Icons.balance_rounded, size: 20),
                label: const Text('Ver Arqueos'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
