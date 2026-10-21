---
type: index
title: Serum Mobile — Módulos Funcionales
description: Índice de los módulos funcionales de la aplicación Serum Mobile, documentando pantallas, vistas, diálogos y flujos de usuario.
tags: [mobile, modules, index, screens, cubits, views]
timestamp: 2026-10-21T16:20:00Z
---

# 📱 Módulos Funcionales — Serum Mobile

Esta sección contiene la especificación funcional detallada de cada pantalla, flujo de usuario, diálogos y cubits correspondientes a la aplicación móvil **Serum Mobile**.

---

## 📑 Módulos Documentados

| Módulo | Documento | Descripción |
| :--- | :--- | :--- |
| **Autenticación y Sesión** | **[auth_y_sesion.md](auth_y_sesion.md)** | Login móvil, validación de permisos de supervisor (`accessLevel > 3`), hidratación de JWT y cierre de sesión. |
| **Dashboard y KPIs** | **[dashboard_kpis.md](dashboard_kpis.md)** | Métricas ejecutivas en tiempo real: ingresos, volumen analítico, turnos activos y banner de órdenes bloqueadas. |
| **Aprobación de Órdenes** | **[aprobacion_ordenes.md](aprobacion_ordenes.md)** | Bandeja de órdenes retenidas (`isBlocked`), tabla comparativa de precios y desbloqueo en 1-tap con o sin justificación. |
| **Órdenes y Visor Clínico** | **[ordenes_y_visor_clinico.md](ordenes_y_visor_clinico.md)** | Buscador de órdenes, expediente del paciente y visor clínico con clasificación de flags médicos (`NORMAL`, `HIGH`, `LOW`, `ABNORMAL`). |
| **Arqueos y Turnos de Caja** | **[arqueos_y_turnos_caja.md](arqueos_y_turnos_caja.md)** | Monitor en vivo de turnos abiertos en sucursales, balances por método de pago y auditoría de discrepancias de cierre. |
| **Reportes Ejecutivos** | **[reportes_ejecutivos.md](reportes_ejecutivos.md)** | Gráficos analíticos con `fl_chart`, rentabilidad, ingresos consolidados y auditoría financiera. |
| **Administración de Usuarios** | **[administracion_usuarios.md](administracion_usuarios.md)** | Directorio institucional de colaboradores y modal móvil para alta de usuarios asignando rol y sucursales. |
