import 'package:intl/intl.dart';

/// Formatea una cantidad en centavos enteros (`int`) a formato de moneda con símbolo.
///
/// Ejemplo:
/// - `formatCentsToCurrency(15050)` -> `"$150.50"`
/// - `formatCentsToCurrency(0)` -> `"$0.00"`
/// - `formatCentsToCurrency(-2500)` -> `"-$25.00"`
String formatCentsToCurrency(int cents, {String currencySymbol = '\$'}) {
  final amount = cents / 100.0;
  return NumberFormat.currency(
    symbol: currencySymbol,
    decimalDigits: 2,
  ).format(amount);
}

/// Formatea una cantidad en centavos enteros (`int`) con signo explícito (`+` o `-`).
///
/// Ejemplo:
/// - `formatCentsSigned(15000)` -> `"+$150.00"`
/// - `formatCentsSigned(-15000)` -> `"-$150.00"`
/// - `formatCentsSigned(0)` -> `"$0.00"`
String formatCentsSigned(int cents, {String currencySymbol = '\$'}) {
  if (cents > 0) return '+${formatCentsToCurrency(cents, currencySymbol: currencySymbol)}';
  return formatCentsToCurrency(cents, currencySymbol: currencySymbol);
}

/// Formatea una cantidad en centavos enteros (`int`) a formato compacto para gráficos o badges reducidos.
///
/// Ejemplo:
/// - `formatCentsToCompact(150000)` -> `"$1.5K"`
String formatCentsToCompact(int cents, {String currencySymbol = '\$'}) {
  final amount = cents / 100.0;
  return NumberFormat.compactCurrency(
    symbol: currencySymbol,
    decimalDigits: 1,
  ).format(amount);
}
