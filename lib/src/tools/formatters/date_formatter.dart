import 'package:intl/intl.dart';

/// Formatea un timestamp Unix en milisegundos (`int`) a formato fecha y hora.
///
/// Ejemplo: `formatTimestampToDateTime(1762281600000)` -> `"04/11/2026 • 07:00 p. m."`
String formatTimestampToDateTime(int timestamp, {String fallback = 'Fecha no disponible'}) {
  if (timestamp <= 0) return fallback;
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat('dd/MM/yyyy • hh:mm a').format(date);
}

/// Formatea un timestamp Unix en milisegundos (`int`) únicamente a fecha (`dd/MM/yyyy`).
String formatTimestampToDate(int timestamp, {String fallback = 'Fecha no disponible'}) {
  if (timestamp <= 0) return fallback;
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat('dd/MM/yyyy').format(date);
}

/// Formatea un timestamp Unix en milisegundos (`int`) únicamente a hora (`hh:mm a`).
String formatTimestampToTime(int timestamp, {String fallback = 'Hora no disponible'}) {
  if (timestamp <= 0) return fallback;
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat('hh:mm a').format(date);
}
