import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';
import 'package:serum_mobile/src/cubits/app_session_cubit/app_session_cubit.dart';
import 'package:serum_mobile/src/cubits/order_cubit/order_mobile_cubit.dart';
import 'package:serum_mobile/src/modules/order/widgets/order_card.dart';
import 'package:serum_mobile/src/widgets/common/app_search_bar.dart';
import 'package:serum_mobile/src/widgets/common/empty_state_view.dart';

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
    final cubit = context.read<OrderMobileCubit>();

    return BlocListener<AppSessionCubit, AppSessionState>(
      listenWhen: (prev, curr) =>
          prev.currentBranch?.id != curr.currentBranch?.id,
      listener: (context, sessionState) {
        cubit.loadOrders();
      },
      child: Scaffold(
        backgroundColor: ColorPalette.surface,
        appBar: AppBar(
          title: const Text('Órdenes Clínicas'),
          actions: [
            IconButton(
              tooltip: 'Actualizar',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => cubit.loadOrders(),
            ),
          ],
        ),
        body: Column(
        children: [
          // Barra de búsqueda unificada
          AppSearchBar(
            controller: _searchController,
            hintText: 'Buscar por folio, paciente o médico...',
            onChanged: cubit.setSearchQuery,
            onClear: () => cubit.setSearchQuery(''),
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
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: EmptyStateView(
                          icon: Icons.search_off_rounded,
                          title: 'Sin coincidencias',
                          message: state.searchQuery.isNotEmpty
                              ? 'No encontramos órdenes para "${state.searchQuery}".'
                              : 'No hay órdenes en la categoría seleccionada.',
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
      ),
    );
  }
}
