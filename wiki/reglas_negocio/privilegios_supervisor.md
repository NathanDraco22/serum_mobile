---
type: concept
title: Regla de Negocio — Privilegios y Auditoría de Supervisión
description: Especificación de niveles de acceso jerárquicos (accessLevel), validación estricta de supervisor en móvil y auditoría inmutable de aprobaciones.
tags: [security, access_level, supervisor, audit, permissions, blocked_orders]
timestamp: 2026-10-21T16:30:00Z
---

# 🛡️ Privilegios y Auditoría de Supervisión

**Serum Mobile** no es una aplicación abierta para todo el personal del laboratorio. Es una herramienta directiva con permisos elevados de supervisión, auditoría y toma de decisiones financieras.

---

## 🎖️ 1. Jerarquía de Niveles de Acceso (`accessLevel`)

El sistema clasifica a los usuarios según su nivel numérico de privilegios:

| Nivel | Rol Típico | Dispositivos Autorizados | Capacidades Principales |
| :---: | :--- | :--- | :--- |
| **1** | Paciente / Consulta web | Portal Web Paciente | Consulta exclusiva de sus propios resultados. |
| **2** | Flebotomista / Recepcionista | Terminal de Ventanilla Desktop | Registro de pacientes, cotizaciones, órdenes con precios de catálogo. |
| **3** | Bioanalista / Químico de Banco | Terminal de Laboratorio Desktop | Validación técnica y captura analítica de resultados de laboratorio. |
| **4** | **Supervisor Clínico** | **Serum Mobile** y Desktop | **Supervisión operativa, consulta de órdenes analíticas, monitoreo de turnos de caja y KPIs de ventas.** |
| **5** | **Director Médico / Dueño / Admin** | **Serum Mobile** y Desktop | **Acceso total y exclusivo: aprobación de órdenes retenidas (`isBlocked`), gestión/alta de usuarios y métricas avanzadas.** |

---

## 🔐 2. Restricción Exclusiva para Administradores en Serum Mobile

En **Serum Mobile**, las funciones críticas de **Aprobación de Órdenes Retenidas** (`/approvals`) y **Administración de Usuarios** (`/users`) están restringidas **exclusivamente a usuarios con privilegios de Administrador** (`AppSessionState.isAdmin`):
- **Criterios de Administrador:**
  1. Usuario Root (`isRootUser`).
  2. Nivel de acceso 5 o superior (`accessLevel >= 5`).
  3. Rol del sistema `'Admin'` o `'Administrador'` (case-insensitive).
- **Comportamiento para Supervisores Operativos (`accessLevel == 4`, no admin):**
  - La barra de navegación inferior oculta las pestañas de *Aprobaciones* y *Usuarios*, mostrando solo 3 destinos (*Inicio*, *Órdenes*, *Cajas*).
  - El enrutador (`AppRouter.redirect`) bloquea cualquier intento de navegación directa redirigiendo a `/dashboard`.
  - El Dashboard oculta el banner de órdenes pendientes de aprobación y la tarjeta *Por Autorizar* de la grilla de KPIs.

---

## 🚫 3. Barrera de Acceso a Serum Mobile

- **Regla Estricta:** El acceso a la aplicación móvil requiere **`accessLevel > 3`**.
- Si un usuario con rol de recepcionista (`accessLevel == 2`) o bioanalista (`accessLevel == 3`) intenta autenticarse en Serum Mobile:
  1. El servidor o el guard de la aplicación rechaza la solicitud.
  2. No se inicializa el estado autenticado en `AppSessionCubit`.
  3. Se despliega un diálogo explicativo indicando que sus credenciales son válidas únicamente en terminales de laboratorio o ventanilla.

---

## 📝 4. Trazabilidad Inmutable de Aprobaciones

Cada vez que un supervisor aprueba una orden bloqueada (`isBlocked == true`) desde su dispositivo móvil:
1. La petición `POST /api/v1/orders/{order_id}/approve` viaja firmada con el Bearer JWT del supervisor.
2. El backend valida el token e inyecta en el documento de la orden:
   - `approvedBy`: ID y nombre del usuario supervisor.
   - `approvedAt`: Marca de tiempo Unix en milisegundos.
   - `approvalReason`: Texto descriptivo (ej. *"Descuento familiar autorizado"* o *"Aprobación móvil por director"*).
   - `isBlocked`: Cambia a `false`.
3. Esta información queda grabada de forma inmutable para futuras auditorías financieras y no puede ser alterada por el personal de ventanilla.
