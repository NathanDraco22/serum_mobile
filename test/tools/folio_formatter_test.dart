import 'package:flutter_test/flutter_test.dart';
import 'package:serum_mobile/src/tools/formatters/folio_formatter.dart';

void main() {
  group('FolioFormatter Tests', () {
    test('formatOrderFolio genera prefijo FOL y corta a 8 caracteres si excede longitud', () {
      expect(formatOrderFolio('67290123456789'), 'FOL-67290123');
      expect(formatOrderFolio('abcdef123456'), 'FOL-ABCDEF12');
    });

    test('formatOrderFolio conserva IDs cortos de menos de 8 caracteres', () {
      expect(formatOrderFolio('abc'), 'FOL-ABC');
      expect(formatOrderFolio('1234'), 'FOL-1234');
    });

    test('formatOrderFolio no duplica el prefijo FOL- si ya existe', () {
      expect(formatOrderFolio('FOL-2026-001'), 'FOL-2026-001');
      expect(formatOrderFolio('fol-999'), 'FOL-999');
    });

    test('formatOrderFolio maneja strings vacíos o con solo espacios', () {
      expect(formatOrderFolio(''), 'FOL-N/A');
      expect(formatOrderFolio('   '), 'FOL-N/A');
    });
  });
}
