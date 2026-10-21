import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/cash_shift_cubit/cash_shift_mobile_cubit.dart';
import 'package:serum_mobile/src/modules/cash_shift/widgets/shift_breakdown_card.dart';

class CashShiftScreen extends StatelessWidget {
  const CashShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CashShiftMobileCubit>(
      create: (ctx) => CashShiftMobileCubit(
        cashShiftsRepository: ctx.read<CashShiftsRepository>(),
      )..loadShifts(),
      child: const _CashShiftView(),
    );
  }
}

class _CashShiftView extends StatefulWidget {
  const _CashShiftView();

  @override
  State<_CashShiftView> createState() => _CashShiftViewState();
}

class _CashShiftViewState extends State<_CashShiftView> {
  final _searchController = TextEditingController();

  final List<({String label, String filter})> _filterTabs = const [
    (label: 'Todos', filter: 'all'),
    (label: 'Abiertos', filter: 'open'),
    (label: 'Cerrados', filter: 'closed'),
    (label: 'Con Descuadre', filter: 'discrepancy'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCents(int cents) {
    final amount = cents / 100.0;
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<CashShiftMobileCubit>();

    return Scaffold(
      backgroundColor: ColorPalette.surface,
      appBar: AppBar(
        title: const Text('Monitor de Arqueos y Caja'),
      ),
      body: Column(
        children: [
          // Métricas Resumen Superior
          BlocBuilder<CashShiftMobileCubit, CashShiftMobileState>(
            builder: (context, state) {
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorPalette.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorPalette.outlineVariant, width: 0.8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryMetric(
                        label: 'Abiertos',
                        value: '${state.activeShiftsCount}',
                        icon: Icons.lock_open_rounded,
                        color: ColorPalette.success,
                      ),
                    ),
                    Container(width: 1, height: 36, color: ColorPalette.outlineVariant),
                    Expanded(
                      child: _buildSummaryMetric(
                        label: 'Recaudado',
                        value: _formatCents(state.totalRevenueCents),
                        icon: Icons.payments_rounded,
                        color: ColorPalette.primary,
                      ),
                    ),
                    Container(width: 1, height: 36, color: ColorPalette.outlineVariant),
                    Expanded(
                      child: _buildSummaryMetric(
                        label: 'Descuadres',
                        value: '${state.discrepancyShiftsCount}',
                        icon: Icons.warning_amber_rounded,
                        color: state.discrepancyShiftsCount > 0
                            ? ColorPalette.error
                            : ColorPalette.success,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Buscador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: cubit.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Buscar por sucursal o cajero...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          cubit.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Chips de Filtro
          BlocBuilder<CashShiftMobileCubit, CashShiftMobileState>(
            buildWhen: (prev, curr) => prev.filter != curr.filter,
            builder: (context, state) {
              return SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filterTabs.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final tab = _filterTabs[index];
                    final isSelected = state.filter == tab.filter;

                    return ChoiceChip(
                      label: Text(tab.label),
                      selected: isSelected,
                      onSelected: (_) => cubit.setFilter(tab.filter),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : ColorPalette.onSurface,
                      ),
                      selectedColor: ColorPalette.primary,
                      backgroundColor: ColorPalette.surfaceContainerLow,
                      side: BorderSide(
                        color: isSelected
                            ? ColorPalette.primary
                            : ColorPalette.outlineVariant,
                        width: 0.8,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Lista de Turnos
          Expanded(
            child: BlocBuilder<CashShiftMobileCubit, CashShiftMobileState>(
              builder: (context, state) {
                if (state.status == CashShiftMobileStatus.loading && state.shifts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.filteredShifts.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => cubit.loadShifts(showLoading: false),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.45,
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.point_of_sale_outlined,
                                size: 52,
                                color: ColorPalette.outline.withAlpha(120),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Sin turnos registrados',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                state.searchQuery.isNotEmpty
                                    ? 'No encontramos turnos para "${state.searchQuery}".'
                                    : 'No hay turnos bajo el filtro seleccionado.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: ColorPalette.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => cubit.loadShifts(showLoading: false),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: state.filteredShifts.length,
                    itemBuilder: (context, index) {
                      final shift = state.filteredShifts[index];
                      return ShiftBreakdownCard(shift: shift);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: ColorPalette.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
