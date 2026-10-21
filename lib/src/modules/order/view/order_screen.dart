import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/order_cubit/order_mobile_cubit.dart';
import 'package:serum_mobile/src/modules/order/widgets/order_card.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderMobileCubit>(
      create: (ctx) => OrderMobileCubit(
        ordersRepository: ctx.read<OrdersRepository>(),
      )..loadOrders(),
      child: const _OrderView(),
    );
  }
}

class _OrderView extends StatefulWidget {
  const _OrderView();

  @override
  State<_OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<_OrderView> {
  final _searchController = TextEditingController();

  final List<({String label, String? status})> _filters = const [
    (label: 'Todas', status: null),
    (label: 'Completadas', status: 'completed'),
    (label: 'En Proceso', status: 'in_process'),
    (label: 'Pendientes', status: 'pending'),
    (label: 'Retenidas', status: 'blocked'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<OrderMobileCubit>();

    return Scaffold(
      backgroundColor: ColorPalette.surface,
      appBar: AppBar(
        title: const Text('Órdenes Clínicas'),
      ),
      body: Column(
        children: [
          // Barra de búsqueda en vivo
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: cubit.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Buscar por folio, paciente o médico...',
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

          // Chips de Filtro por Estado
          BlocBuilder<OrderMobileCubit, OrderMobileState>(
            buildWhen: (prev, curr) => prev.statusFilter != curr.statusFilter,
            builder: (context, state) {
              return SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = state.statusFilter == filter.status;

                    return ChoiceChip(
                      label: Text(filter.label),
                      selected: isSelected,
                      onSelected: (_) => cubit.setStatusFilter(filter.status),
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

          // Lista de Órdenes
          Expanded(
            child: BlocBuilder<OrderMobileCubit, OrderMobileState>(
              builder: (context, state) {
                if (state.status == OrderMobileStatus.loading && state.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.filteredOrders.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => cubit.loadOrders(showLoading: false),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.55,
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 52,
                                color: ColorPalette.outline.withAlpha(120),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Sin coincidencias',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                state.searchQuery.isNotEmpty
                                    ? 'No encontramos órdenes para "${state.searchQuery}".'
                                    : 'No hay órdenes en la categoría seleccionada.',
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
                  onRefresh: () => cubit.loadOrders(showLoading: false),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: state.filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = state.filteredOrders[index];
                      return OrderCard(order: order);
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
}
