import 'package:flutter/material.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';

/// Tarjeta que despliega la información del supervisor en sesión y su sucursal.
class SupervisorHeaderCard extends StatelessWidget {
  final UserInDb? user;
  final BranchInDb? branch;
  final VoidCallback? onTapBranch;

  const SupervisorHeaderCard({
    super.key,
    required this.user,
    required this.branch,
    this.onTapBranch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = (user?.name.isNotEmpty ?? false)
        ? user!.name[0].toUpperCase()
        : 'S';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorPalette.outlineVariant,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: ColorPalette.primary.withAlpha(30),
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ColorPalette.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Supervisor',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                _buildBranchIndicator(theme),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: ColorPalette.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Nivel ${user?.accessLevel ?? 4}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColorPalette.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchIndicator(ThemeData theme) {
    final branchName = branch?.name ?? 'Sede Principal';

    if (onTapBranch == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_rounded,
            size: 14,
            color: ColorPalette.primary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              branchName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ColorPalette.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: onTapBranch,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 14,
              color: ColorPalette.primary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                branchName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ColorPalette.primary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: ColorPalette.primary,
            ),
          ],
        ),
      ),
    );
  }
}
