import 'package:flutter_test/flutter_test.dart';
import 'package:serum_mobile/src/tools/formatters/date_formatter.dart';

void main() {
  group('DateFormatter Tests', () {
    test('formatTimestampToDateTime formatea un timestamp Unix válido', () {
      // 2026-11-04 15:30:00 UTC = 1793806200000 ms
      final dt = DateTime(2026, 11, 4, 15, 30);
      final formatted = formatTimestampToDateTime(dt.millisecondsSinceEpoch);
      expect(formatted.contains('04/11/2026'), isTrue);
      expect(formatted.contains('•'), isTrue);
    });

    test('formatTimestampToDateTime retorna fallback para timestamp inválido o menor a cero', () {
      expect(formatTimestampToDateTime(0), 'Fecha no disponible');
      expect(formatTimestampToDateTime(-1), 'Fecha no disponible');
      expect(formatTimestampToDateTime(-100, fallback: 'Sin fecha'), 'Sin fecha');
    });

    test('formatTimestampToDate formatea fecha sin hora', () {
      final dt = DateTime(2026, 11, 4);
      expect(formatTimestampToDate(dt.millisecondsSinceEpoch), '04/11/2026');
      expect(formatTimestampToDate(0), 'Fecha no disponible');
    });

    test('formatTimestampToTime formatea hora sin fecha', () {
      final dt = DateTime(2026, 11, 4, 14, 25);
      final timeStr = formatTimestampToTime(dt.millisecondsSinceEpoch);
      expect(timeStr.contains('02:25') || timeStr.contains('2:25'), isTrue);
      expect(formatTimestampToTime(0), 'Hora no disponible');
    });
  });
}
