import 'package:flutter/material.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';

class UserCard extends StatelessWidget {
  final UserInDb user;
  final List<BranchInDb> allBranches;

  const UserCard({
    super.key,
    required this.user,
    required this.allBranches,
  });

  Color _getAccessColor(int level) {
    if (level >= 4) return ColorPalette.primary;
    if (level == 3) return ColorPalette.secondary;
    return ColorPalette.tertiary;
  }

  List<String> _resolveBranchNames() {
    if (user.branches.isEmpty) return ['Todas las sedes'];
    return user.branches.map((bId) {
      final found = allBranches.where((b) => b.id == bId);
      if (found.isNotEmpty) return found.first.name;
      return bId;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accessColor = _getAccessColor(user.accessLevel);
    final branchNames = _resolveBranchNames();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorPalette.outlineVariant,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Nombre, Username y Badge de Estado
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accessColor.withAlpha(25),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accessColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorPalette.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorPalette.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Chip de Estado Activo/Inactivo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? ColorPalette.success.withAlpha(20)
                      : ColorPalette.outlineVariant.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: user.isActive
                            ? ColorPalette.success
                            : ColorPalette.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      user.isActive ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: user.isActive
                            ? ColorPalette.success
                            : ColorPalette.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rol y Nivel de Acceso
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accessColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accessColor.withAlpha(60),
                    width: 0.6,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 13,
                      color: accessColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: accessColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Nivel ${user.accessLevel}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: ColorPalette.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Datos de contacto (Correo y Teléfono si existen)
          if ((user.email != null && user.email!.isNotEmpty) ||
              (user.phone != null && user.phone!.isNotEmpty)) ...[
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if (user.email != null && user.email!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: ColorPalette.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.email!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ColorPalette.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                if (user.phone != null && user.phone!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: ColorPalette.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.phone!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ColorPalette.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          const Divider(
            height: 12,
            thickness: 0.6,
            color: ColorPalette.outlineVariant,
          ),
          const SizedBox(height: 6),

          // Sedes Asignadas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 15,
                color: ColorPalette.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: branchNames.map((name) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ColorPalette.surfaceContainerHighest.withAlpha(50),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        name,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: ColorPalette.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
