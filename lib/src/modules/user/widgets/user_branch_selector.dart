import 'package:flutter/material.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';

/// Selector múltiple de sucursales mediante FilterChips para el formulario de usuario.
class UserBranchSelector extends StatelessWidget {
  final List<BranchInDb> branches;
  final Set<String> selectedBranchIds;
  final ValueChanged<Set<String>> onChanged;

  const UserBranchSelector({
    super.key,
    required this.branches,
    required this.selectedBranchIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sucursales Autorizadas',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: ColorPalette.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        if (branches.isEmpty) ...[
          Text(
            'No hay sucursales registradas (se asignará global).',
            style: theme.textTheme.bodySmall?.copyWith(
              color: ColorPalette.onSurfaceVariant,
            ),
          ),
        ] else ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: branches.map((b) {
              final isSelected = selectedBranchIds.contains(b.id);
              return FilterChip(
                label: Text(b.name),
                selected: isSelected,
                onSelected: (selected) {
                  final updated = Set<String>.from(selectedBranchIds);
                  if (selected) {
                    updated.add(b.id);
                  } else {
                    updated.remove(b.id);
                  }
                  onChanged(updated);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
