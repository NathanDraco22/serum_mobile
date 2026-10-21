---
type: module
title: Módulo — Órdenes Clínicas y Visor de Resultados
description: Especificación de la búsqueda reactiva de órdenes médicas, expediente del paciente y visor clínico de parámetros analíticos con badges de flags de laboratorio.
tags: [orders, clinical_results, medical_flags, lab_tests, visor, patient]
timestamp: 2026-10-21T16:24:00Z
---

# 🩺 Órdenes Clínicas y Visor de Resultados

Este módulo permite a los directores y supervisores médicos consultar el histórico de órdenes, buscar estudios por paciente o folio en tiempo real y **revisar de forma inmediata los resultados analíticos** capturados por el laboratorio.

---

## 🎯 1. Objetivos del Módulo

1. **Búsqueda Instantánea:** Filtrar órdenes por nombre de paciente, folio clínico o rango de fechas con debounce de 300ms.
2. **Supervisión Médica:** Consultar el estado del procesamiento (`PENDING`, `IN_PROCESS`, `COMPLETED`).
3. **Visor Clínico Ergonómico:** Presentar los valores analíticos obtenidos comparados contra los rangos de referencia, destacando inmediatamente cualquier anomalía médica.

---

## 🗂️ 2. Estructura de Archivos

```
serum_mobile/lib/
├── src/
│   ├── cubits/
│   │   └── order_cubit/
│   │       ├── order_mobile_cubit.dart
│   │       └── order_mobile_state.dart
│   └── modules/
│       └── order/
│           ├── view/
│           │   ├── order_screen.dart           # Lista con buscador en vivo
│           │   └── order_detail_screen.dart    # Vista extendida de orden
│           └── widgets/
│               ├── order_card.dart             # Tarjeta resumen de orden
│               ├── order_results_modal.dart    # Visor de resultados analíticos
│               └── test_result_parameter_row.dart # Fila con valor, unidad y rango
```

---

## 🧬 3. Visor Clínico y Sistema de Flags Médicos

Cada parámetro de una prueba clínica procesada se visualiza con su valor reportado, unidad de medida y rango de referencia según la edad y género del paciente.

El widget `MedicalFlagBadge` (`src/widgets/common/medical_flag_badge.dart`) interpreta los flags clínicos:

| Flag Clínico | Significado | Representación Visual |
| :--- | :--- | :--- |
| **`NORMAL`** | Valor dentro del rango de referencia biológico. | Chip verde esmeralda sutil con texto "Normal". |
| **`HIGH`** | Valor por encima del límite superior. | Chip ámbar/rojo con icono de flecha hacia arriba (▲ `ALTO`). |
| **`LOW`** | Valor por debajo del límite inferior. | Chip azul/ámbar con icono de flecha hacia abajo (▼ `BAJO`). |
| **`ABNORMAL`** | Resultado reactivo o patológico cualitativo (ej. VDRL Reactivo, Covid Positivo). | Chip rojo de alta prioridad con icono de alerta (⚠️ `ANORMAL`). |

### Ejemplo Visual en la Fila del Visor:
```
Glucosa en Suero
Valor: 142 mg/dL       Rango: 70 - 100 mg/dL       [ ▲ ALTO ]
```

---

## 🚫 4. Límite Operativo en Móvil

> ⚠️ **REGLA ESTRICTA DE SOLO LECTURA:**
> Serum Mobile **NO permite capturar ni editar resultados clínicos**. La captura y validación analítica es responsabilidad del personal bioanalista en la terminal de laboratorio (`serum_app_front`). En el móvil, el supervisor únicamente audita y consulta la información.
