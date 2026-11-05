import 'package:flutter_test/flutter_test.dart';
import 'package:serum_mobile/src/tools/formatters/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formatCentsToCurrency formatea enteros positivos a divisa con centavos', () {
      expect(formatCentsToCurrency(15050), '\$150.50');
      expect(formatCentsToCurrency(100), '\$1.00');
      expect(formatCentsToCurrency(50), '\$0.50');
      expect(formatCentsToCurrency(245000), '\$2,450.00');
    });

    test('formatCentsToCurrency formatea 0 correctamente', () {
      expect(formatCentsToCurrency(0), '\$0.00');
    });

    test('formatCentsToCurrency formatea valores negativos correctamente', () {
      expect(formatCentsToCurrency(-2500), '-\$25.00');
      expect(formatCentsToCurrency(-150000), '-\$1,500.00');
    });

    test('formatCentsSigned agrega prefijo "+" a valores positivos y conserva "-"', () {
      expect(formatCentsSigned(15000), '+\$150.00');
      expect(formatCentsSigned(-15000), '-\$150.00');
      expect(formatCentsSigned(0), '\$0.00');
    });

    test('formatCentsToCompact formatea valores grandes en formato abreviado', () {
      expect(formatCentsToCompact(150000), '\$1.5K');
    });
  });
}
