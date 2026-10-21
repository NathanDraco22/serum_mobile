---
type: module
title: Módulo — Arqueos y Monitor de Turnos de Caja
description: Especificación del monitoreo en vivo de turnos de caja (CashShift) en todas las sedes, balances por método de pago y detección de discrepancias de cierre.
tags: [cash_shift, cash_registers, balances, discrepancies, pos, audit]
timestamp: 2026-10-21T16:25:00Z
---

# 💰 Arqueos y Monitor de Turnos de Caja

Este módulo proporciona a los administradores y directores una ventana de supervisión en tiempo real sobre los turnos de caja (`CashShift`) activos y cerrados en cada una de las sucursales del laboratorio.

---

## 🎯 1. Objetivos del Módulo

1. **Monitoreo en Tiempo Real:** Saber con exactitud qué cajas físicas están abiertas, quién es el operador a cargo y a qué hora inició el turno.
2. **Desglose Multimétodo:** Conocer los fondos recaudados en tiempo real desglosados por método de pago:
   - Efectivo físico en caja (`cash`).
   - Terminales de punto de venta / Tarjetas bancarias (`card`).
   - Transferencias electrónicas (`transfer`).
3. **Auditoría de Descuadres:** Resaltar de inmediato en color rojo cualquier turno cerrado con discrepancia entre el monto esperado y el declarado por el cajero.

---

## 🗂️ 2. Estructura de Archivos

```
serum_mobile/lib/
├── src/
│   ├── cubits/
│   │   └── cash_shift_cubit/
│   │       ├── cash_shift_mobile_cubit.dart
│   │       └── cash_shift_mobile_state.dart
│   └── modules/
│       └── cash_shift/
│           ├── view/
│           │   └── cash_shift_screen.dart
│           └── widgets/
│               ├── shift_status_card.dart
│               ├── shift_breakdown_card.dart
│               └── discrepancy_badge.dart
```

---

## 💳 3. Componentes de la Tarjeta de Turno (`ShiftBreakdownCard`)

Cada tarjeta de turno de caja presenta:
1. **Identificación:** Nombre de la caja registradora, sucursal a la que pertenece y nombre del cajero responsable.
2. **Estado del Turno:**
   - `OPEN`: Badge verde con tiempo transcurrido desde la apertura.
   - `CLOSED`: Badge gris con fecha/hora de cierre.
3. **Fondos y Balances (en Centavos Formateados):**
   - Fondo Inicial de Apertura (`initialBalanceCents`).
   - Ingresos en Efectivo (`cashSalesCents`).
   - Cobros con Tarjeta (`cardSalesCents`).
   - Cobros por Transferencia (`transferSalesCents`).
   - Egresos / Retiros de caja chica (`cashOutCents`).
   - **Balance Total Esperado (`expectedBalanceCents`)**.
4. **Auditoría de Cierre (Solo en turnos cerrados):**
   - Monto Declarado por el Cajero (`declaredBalanceCents`).
   - **Discrepancia (`differenceCents`):**
     - Si es `0`: Chip verde *"Corte Cuadrado"*.
     - Si es `< 0`: Chip rojo *"Faltante de \$X.XX"*.
     - Si es `> 0`: Chip ámbar *"Sobrante de \$X.XX"*.

---

## 🚫 4. Límite Operativo en Móvil

> ⚠️ **NO ES UN POS DE COBRO:**
> Serum Mobile **NO realiza aperturas de turno, cortes de caja ni cobros de mostrador**. Estas acciones se realizan en el hardware físico de cada sucursal (`serum_app_front`). El módulo móvil es exclusivamente de **auditoría, consulta y control gerencial**.
