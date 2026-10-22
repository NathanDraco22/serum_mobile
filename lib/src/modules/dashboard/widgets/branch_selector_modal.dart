import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';

/// Modal inferior para seleccionar y alternar de sucursal en Serum Mobile.
class BranchSelectorModal extends StatelessWidget {
  final List<BranchInDb> branches;
  final BranchInDb? currentBranch;
  final ValueChanged<BranchInDb>? onBranchSelected;

  const BranchSelectorModal({
    super.key,
    required this.branches,
    required this.currentBranch,
    this.onBranchSelected,
  });

  /// Muestra el modal selector de sucursales y retorna la sucursal elegida.
  static Future<BranchInDb?> show(
    BuildContext context, {
    required List<BranchInDb> branches,
    required BranchInDb? currentBranch,
  }) {
    return showModalBottomSheet<BranchInDb>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorPalette.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => BranchSelectorModal(
        branches: branches,
        currentBranch: currentBranch,
        onBranchSelected: (selectedBranch) {
          context.read<AppSessionCubit>().selectBranch(selectedBranch);
          Navigator.of(modalContext).pop(selectedBranch);
        },
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
              // Barra de arrastre (Drag handle)
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

              // Encabezado
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
                          'Seleccionar Sucursal',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Elige la sede para consultar sus métricas y reportes',
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

              // Lista de Sucursales
              Flexible(
                child: branches.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'No hay sucursales disponibles.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: ColorPalette.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: branches.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final branch = branches[index];
                          final isSelected = branch.id == currentBranch?.id;

                          return InkWell(
                            onTap: () {
                              if (onBranchSelected != null) {
                                onBranchSelected!(branch);
                              } else {
                                Navigator.of(context).pop(branch);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? ColorPalette.primary.withAlpha(18)
                                    : ColorPalette.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? ColorPalette.primary
                                      : ColorPalette.outlineVariant,
                                  width: isSelected ? 1.4 : 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isSelected
                                        ? ColorPalette.primary
                                        : ColorPalette.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      size: 18,
                                      color: isSelected
                                          ? Colors.white
                                          : ColorPalette.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          branch.name,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? ColorPalette.primary
                                                : null,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (branch.address.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            branch.address,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color:
                                                  ColorPalette.onSurfaceVariant,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: ColorPalette.primary,
                                      size: 20,
                                    )
                                  else
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: ColorPalette.onSurfaceVariant,
                                      size: 14,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
