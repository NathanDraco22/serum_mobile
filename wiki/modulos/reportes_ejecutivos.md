---
type: module
title: Módulo — Reportes Ejecutivos y Analíticas Financieras
description: Especificación de reportes de rentabilidad, volumen analítico, gráficos con fl_chart y filtros por períodos de tiempo.
tags: [reports, analytics, fl_chart, finance, volume, charts]
timestamp: 2026-10-21T16:26:00Z
---

# 📈 Reportes Ejecutivos y Analíticas Financieras

El módulo de **Reportes** ofrece a la alta dirección del laboratorio gráficos visuales interactivos y métricas financieras consolidadas para la toma de decisiones estratégicas.

---

## 🎯 1. Objetivos del Módulo

1. **Rentabilidad y Ventas:** Visualizar ingresos brutos, descuentos aplicados e ingresos netos desglosados por día, semana o mes.
2. **Volumen de Exámenes:** Identificar los estudios y paquetes más solicitados por los pacientes.
3. **Auditoría de Descuadres:** Resumir el total de discrepancias acumuladas en turnos de caja por sucursal.
4. **Interactividad Táctil:** Gráficos responsivos y optimizados para dispositivos móviles utilizando la librería `fl_chart`.

---

## 🗂️ 2. Estructura de Archivos

```
serum_mobile/lib/
├── src/
│   ├── cubits/
│   │   └── report_cubit/
│   │       ├── report_mobile_cubit.dart
│   │       └── report_mobile_state.dart
│   └── modules/
│       └── report/
│           ├── view/
│           │   └── report_screen.dart
│           └── widgets/
│               ├── date_range_selector.dart    # Filtros: Hoy, Semana, Mes, Personalizado
│               ├── revenue_bar_chart.dart      # Gráfico de barras de ingresos (fl_chart)
│               ├── test_volume_pie_chart.dart  # Gráfico circular de pruebas top (fl_chart)
│               └── financial_metric_card.dart  # Tarjetas de totales (ingresos, descuentos)
```

---

## 📊 3. Visualizaciones con `fl_chart`

### 1. Gráfico de Ingresos por Período (`RevenueBarChart`):
- Gráfico de barras (`BarChart`) que despliega la evolución de cobros diarios o semanales.
- Barras de dos tonos: monto cobrado en efectivo vs métodos electrónicos.
- Tooltips interactivos al tocar una barra mostrando el total en pesos y centavos.

### 2. Distribución de Pruebas Clínicas (`TestVolumePieChart`):
- Gráfico circular (`PieChart`) con el Top 5 de análisis más solicitados (ej. Biometría Hemática, Química Sanguínea, Perfil Lipídico, Examen General de Orina, Perfil Tiroideo) y agrupación "Otros".

---

## ⏱️ 4. Filtros Temporales Dinámicos

La vista incluye un selector segmentado horizontal ergonómico con opciones predefinidas:
- **Hoy**: Datos acumulados de la jornada actual.
- **Esta Semana**: Desde el lunes hasta el momento actual.
- **Este Mes**: Acumulado del mes calendario en curso.
- **Personalizado**: Selector de rango de fechas mediante date picker adaptativo.
