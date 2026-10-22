import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/report_cubit/report_mobile_state.dart';

class DateRangeSelector extends StatelessWidget {
  final ReportTimeFilter activeFilter;
  final int startDate;
  final int endDate;
  final ValueChanged<ReportTimeFilter> onFilterSelected;
  final Function(DateTime start, DateTime end) onCustomRangeSelected;

  const DateRangeSelector({
    super.key,
    required this.activeFilter,
    required this.startDate,
    required this.endDate,
    required this.onFilterSelected,
    required this.onCustomRangeSelected,
  });

  String _formatDateRange() {
    if (startDate == 0 || endDate == 0) return '';
    final start = DateTime.fromMillisecondsSinceEpoch(startDate);
    final end = DateTime.fromMillisecondsSinceEpoch(endDate);

    try {
      final fmt = DateFormat('dd MMM yyyy', 'es');
      if (start.year == end.year &&
          start.month == end.month &&
          start.day == end.day) {
        return fmt.format(start);
      }
      return '${fmt.format(start)} — ${fmt.format(end)}';
    } catch (_) {
      // Fallback seguro en caso de que los símbolos de localización no estén cargados
      final fallbackFmt = DateFormat('dd/MM/yyyy');
      if (start.year == end.year &&
          start.month == end.month &&
          start.day == end.day) {
        return fallbackFmt.format(start);
      }
      return '${fallbackFmt.format(start)} — ${fallbackFmt.format(end)}';
    }
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final initialStart = startDate > 0
        ? DateTime.fromMillisecondsSinceEpoch(startDate)
        : now.subtract(const Duration(days: 7));
    final initialEnd =
        endDate > 0 ? DateTime.fromMillisecondsSinceEpoch(endDate) : now;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      initialDateRange: DateTimeRange(
        start: initialStart.isBefore(initialEnd) ? initialStart : initialEnd,
        end: initialEnd,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: ColorPalette.primary,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onCustomRangeSelected(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Periodo de Análisis',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ColorPalette.primary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: ColorPalette.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateRange(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ColorPalette.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Hoy',
                  isSelected: activeFilter == ReportTimeFilter.today,
                  onTap: () => onFilterSelected(ReportTimeFilter.today),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Esta Semana',
                  isSelected: activeFilter == ReportTimeFilter.thisWeek,
                  onTap: () => onFilterSelected(ReportTimeFilter.thisWeek),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Este Mes',
                  isSelected: activeFilter == ReportTimeFilter.thisMonth,
                  onTap: () => onFilterSelected(ReportTimeFilter.thisMonth),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Personalizado',
                  icon: Icons.date_range_rounded,
                  isSelected: activeFilter == ReportTimeFilter.custom,
                  onTap: () => _pickCustomRange(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorPalette.primary
              : ColorPalette.surfaceContainerHighest.withAlpha(50),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ColorPalette.primary
                : ColorPalette.outlineVariant,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : ColorPalette.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : ColorPalette.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
