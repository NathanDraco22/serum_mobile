---
type: module
title: Módulo — Dashboard Ejecutivo y KPIs
description: Especificación de la vista principal de Serum Mobile, tarjetas de métricas en tiempo real, ingresos formateados en centavos y banner de órdenes bloqueadas.
tags: [dashboard, kpi, metrics, banner, sales, cash_shift, approvals]
timestamp: 2026-10-21T16:22:00Z
---

# 📊 Dashboard Ejecutivo y KPIs

El **Dashboard** es la vista inicial que recibe al supervisor al abrir la aplicación móvil. Ofrece un panorama holístico del desempeño clínico y financiero del laboratorio durante el día en curso.

---

## 🎯 1. Objetivos de la Pantalla

1. **Visibilidad Inmediata:** Mostrar el pulso del día en menos de 3 segundos (ingresos, órdenes, pruebas procesadas y estado de cajas).
2. **Acción Rápida de Autorización:** Destacar de forma prioritaria el número de órdenes que están detenidas en ventanilla esperando autorización del supervisor.
3. **Monitoreo Multisede:** Resumen del estado de los turnos de caja en todas las sucursales.

---

## 🗂️ 2. Estructura de Componentes

```
serum_mobile/lib/src/modules/dashboard/
├── view/
│   └── dashboard_screen.dart
└── widgets/
    ├── dashboard_header.dart           # Saludo personalizado, fecha y avatar de supervisor
    ├── pending_approvals_banner.dart   # Banner reactivo de alerta si isBlocked > 0
    ├── kpi_summary_grid.dart           # Cuadrícula adaptativa 2x2 de métricas clave
    └── active_shifts_preview.dart      # Lista horizontal de cajas abiertas por sucursal
```

---

## 📈 3. Tarjetas KPI del Dashboard

| Métrica | Origen de Datos | Formateo / Visualización |
| :--- | :--- | :--- |
| **Venta del Día** | `ReportsRepository.getDailySummary()` o agregación de órdenes del día | Monto en centavos formateado a moneda: `\$14,250.00 MXN`. |
| **Órdenes del Día** | `OrdersRepository.watchOrders()` | Total de órdenes creadas hoy (ej. `34 órdenes`). |
| **Estudios Procesados** | Conteo de tests contenidos en las órdenes activas | Total de pruebas clínicas analizadas hoy. |
| **Cajas Operativas** | `CashShiftsRepository.watchActiveShifts()` | Cajas con turno abierto respecto al total de cajas registradas (ej. `3 de 4 cajas abiertas`). |

---

## ⚠️ 4. Banner de Aprobaciones Pendientes (`PendingApprovalsBanner`)

Si el repositorio de órdenes detecta una o más órdenes con `isBlocked == true`:
- El banner se renderiza prominentemente en la parte superior del Dashboard con fondo de alerta ámbar (`#D97706`).
- Texto: *"⚠️ Tienes X órdenes retenidas por descuento especial esperando tu autorización"*.
- Al pulsar el banner, `go_router` redirige instantáneamente a la pestaña de **Aprobaciones** (`/approvals`).
- Si no hay órdenes bloqueadas, el banner muestra un estado sereno en verde: *"✅ Sin órdenes pendientes de autorización"*.
