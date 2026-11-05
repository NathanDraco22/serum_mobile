/// Formatea el identificador o ID de orden a un folio clínico visualmente legible.
///
/// Ejemplo:
/// - `formatOrderFolio("67290123456789")` -> `"FOL-67290123"`
/// - `formatOrderFolio("abc")` -> `"FOL-ABC"`
/// - `formatOrderFolio("")` -> `"FOL-N/A"`
String formatOrderFolio(String id) {
  if (id.trim().isEmpty) return 'FOL-N/A';
  final trimmed = id.trim().toUpperCase();
  if (trimmed.startsWith('FOL-')) return trimmed;
  if (trimmed.length >= 8) {
    return 'FOL-${trimmed.substring(0, 8)}';
  }
  return 'FOL-$trimmed';
}
