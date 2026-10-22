import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serum_business/serum_business.dart';
import 'package:serum_mobile/config/app_theme.dart';

class PaymentMethodsChart extends StatefulWidget {
  final PaymentMethodsBreakdown breakdown;

  const PaymentMethodsChart({
    super.key,
    required this.breakdown,
  });

  @override
  State<PaymentMethodsChart> createState() => _PaymentMethodsChartState();
}

class _PaymentMethodsChartState extends State<PaymentMethodsChart> {
  int _touchedIndex = -1;

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
    final cash = widget.breakdown.cash;
    final card = widget.breakdown.card;
    final transfer = widget.breakdown.transfer;
    final total = cash + card + transfer;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pie_chart_rounded,
                color: ColorPalette.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Distribución por Método de Pago',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ColorPalette.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (total == 0) ...[
            Container(
              height: 140,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 36,
                    color: ColorPalette.onSurfaceVariant.withAlpha(120),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sin recaudación en este periodo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ColorPalette.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 160,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 3,
                        centerSpaceRadius: 36,
                        sections: _buildSections(total, cash, card, transfer),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MethodLegendItem(
                        label: 'Efectivo',
                        amount: _formatCents(cash),
                        percentage: (cash / total) * 100,
                        color: ColorPalette.primary,
                        isHighlighted: _touchedIndex == 0,
                      ),
                      const SizedBox(height: 10),
                      _MethodLegendItem(
                        label: 'Tarjetas',
                        amount: _formatCents(card),
                        percentage: (card / total) * 100,
                        color: ColorPalette.secondary,
                        isHighlighted: _touchedIndex == 1,
                      ),
                      const SizedBox(height: 10),
                      _MethodLegendItem(
                        label: 'Transferencias',
                        amount: _formatCents(transfer),
                        percentage: (transfer / total) * 100,
                        color: ColorPalette.tertiary,
                        isHighlighted: _touchedIndex == 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
    int total,
    int cash,
    int card,
    int transfer,
  ) {
    final sections = <PieChartSectionData>[];

    // Efectivo (index 0)
    if (cash > 0) {
      final isTouched = _touchedIndex == 0;
      final pct = (cash / total) * 100;
      sections.add(
        PieChartSectionData(
          color: ColorPalette.primary,
          value: cash.toDouble(),
          title: '${pct.toStringAsFixed(0)}%',
          radius: isTouched ? 48 : 42,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    // Tarjetas (index 1)
    if (card > 0) {
      final isTouched = _touchedIndex == 1;
      final pct = (card / total) * 100;
      sections.add(
        PieChartSectionData(
          color: ColorPalette.secondary,
          value: card.toDouble(),
          title: '${pct.toStringAsFixed(0)}%',
          radius: isTouched ? 48 : 42,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    // Transferencia (index 2)
    if (transfer > 0) {
      final isTouched = _touchedIndex == 2;
      final pct = (transfer / total) * 100;
      sections.add(
        PieChartSectionData(
          color: ColorPalette.tertiary,
          value: transfer.toDouble(),
          title: '${pct.toStringAsFixed(0)}%',
          radius: isTouched ? 48 : 42,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }
}

class _MethodLegendItem extends StatelessWidget {
  final String label;
  final String amount;
  final double percentage;
  final Color color;
  final bool isHighlighted;

  const _MethodLegendItem({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withAlpha(25) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                Text(
                  amount,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ColorPalette.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
