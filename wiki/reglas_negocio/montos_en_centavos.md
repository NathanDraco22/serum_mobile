---
type: concept
title: Regla de Negocio — Montos Monetarios en Centavos
description: Política estricta de cálculo y persistencia monetaria utilizando enteros (int) en centavos para eliminar errores de redondeo de punto flotante.
tags: [currency, cents, int, formatting, finance, precision]
timestamp: 2026-10-21T16:29:00Z
---

# 🪙 Montos Monetarios en Centavos (`int`)

En todo el ecosistema **Serum LIS**, incluyendo la aplicación móvil **Serum Mobile**, el cálculo, almacenamiento y transmisión de valores monetarios sigue una **política de tolerancia cero a errores de redondeo**.

---

## 🚫 1. Prohibición de Punto Flotante (`double`)

- **Bajo ninguna circunstancia** se debe utilizar el tipo primitivo `double` para representar precios, costos, subtotales, impuestos, abonos o balances de arqueo en variables de estado o lógica de negocio.
- **Problema conocido de `double`:** Operaciones como `0.1 + 0.2` producen `0.30000000000000004`, lo que en transacciones contables genera descuadres acumulados en turnos de caja y discrepancias de auditoría.

---

## 🎯 2. Estándar de Representación en Centavos

- Todas las cantidades de dinero se expresan en **centavos enteros (`int`)**:
  - \$1.00 MXN se representa como `100`.
  - \$150.50 MXN se representa como `15050`.
  - \$2,400.00 MXN se representa como `240000`.

---

## 🛠️ 3. Formateo y Visualización en UI

La transformación a formato decimal con signo de moneda se realiza **únicamente en la capa de presentación**, empleando formateadores centralizados ubicados en `lib/src/tools/formatters/`:

```dart
// Función estándar de formateo en Serum Mobile
String formatCentsToCurrency(int cents, {String currencySymbol = '\$'}) {
  final amount = cents / 100.0;
  return NumberFormat.currency(
    symbol: currencySymbol,
    decimalDigits: 2,
  ).format(amount);
}
```

### Ejemplos de Salida:
- `145000` ➔ `"\$1,450.00"`
- `50` ➔ `"\$0.50"`
- `-25000` ➔ `"-\$250.00"`

---

## 🧮 4. Cálculos y Agregaciones en el Móvil

Todas las sumatorias de tarjetas KPI (ingresos del día, balances esperados de turnos, descuentos otorgados) se realizan sumando enteros:

```dart
final int totalRevenueCents = orders.fold(0, (sum, order) => sum + order.totalCents);
```
