import 'package:flutter/material.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';

class ReportBranchFilterModal extends StatelessWidget {
  final List<BranchInDb> branches;
  final String? currentBranchId;
  final ValueChanged<String?> onBranchSelected;

  const ReportBranchFilterModal({
    super.key,
    required this.branches,
    required this.currentBranchId,
    required this.onBranchSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required List<BranchInDb> branches,
    required String? currentBranchId,
    required ValueChanged<String?> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorPalette.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ReportBranchFilterModal(
        branches: branches,
        currentBranchId: currentBranchId,
        onBranchSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * 0.75,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorPalette.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorPalette.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: ColorPalette.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filtrar por Sede',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Elige una sucursal o consulta el consolidado de toda la red',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ColorPalette.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: ColorPalette.outlineVariant),
              const SizedBox(height: 12),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // Opción: Todas las sucursales
                    _buildBranchOption(
                      context: context,
                      title: 'Todas las Sucursales',
                      subtitle: 'Consolidado global de la red',
                      icon: Icons.corporate_fare_rounded,
                      isSelected: currentBranchId == null,
                      onTap: () {
                        onBranchSelected(null);
                        Navigator.of(context).pop();
                      },
                    ),
                    const Divider(height: 1, color: ColorPalette.outlineVariant),
                    ...branches.map((branch) {
                      return _buildBranchOption(
                        context: context,
                        title: branch.name,
                        subtitle: branch.address.isNotEmpty
                            ? branch.address
                            : 'Sede operativa',
                        icon: Icons.store_rounded,
                        isSelected: currentBranchId == branch.id,
                        onTap: () {
                          onBranchSelected(branch.id);
                          Navigator.of(context).pop();
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorPalette.primary.withAlpha(25)
              : ColorPalette.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? ColorPalette.primary : ColorPalette.outline,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected ? ColorPalette.primary : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: ColorPalette.onSurfaceVariant,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle_rounded,
              color: ColorPalette.primary,
              size: 22,
            )
          : null,
    );
  }
}
