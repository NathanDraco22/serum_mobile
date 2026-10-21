---
type: module
title: Módulo — Bandeja y Aprobación de Órdenes Bloqueadas
description: Especificación de la bandeja de órdenes retenidas (isBlocked == true), detalle de discrepancias de precios y flujo de autorización en 1-tap.
tags: [approvals, blocked_orders, discounts, supervisor, workflow, 1tap]
timestamp: 2026-10-21T16:23:00Z
---

# ⚠️ Bandeja y Aprobación de Órdenes Bloqueadas

Este módulo es una de las **funciones medulares y de mayor impacto operativo** de **Serum Mobile**. Permite a los supervisores desbloquear en segundos órdenes que han sido retenidas en el punto de venta de cualquier sucursal debido a modificaciones de precio o descuentos especiales no autorizados automáticamente.

---

## 🎯 1. Justificación y Regla de Bloqueo

En el sistema de ventanilla (`serum_app_front`), cuando un recepcionista o cajero aplica un descuento manual a un examen o paquete que excede su umbral permitido, la orden se registra con la propiedad:
```json
"isBlocked": true,
"blockedReason": "Descuento del 25% excede límite permitido de cajero (10%)"
```
Una orden bloqueada:
- No permite imprimir recibos definitivos.
- No permite pasar la muestra a procesamiento clínico.
- Requiere autorización formal de un supervisor (`accessLevel > 3`).

---

## 🗂️ 2. Estructura de Archivos

```
serum_mobile/lib/
├── src/
│   ├── cubits/
│   │   └── approvals_cubit/
│   │       ├── approvals_cubit.dart
│   │       └── approvals_state.dart
│   └── modules/
│       └── approvals/
│           ├── view/
│           │   └── approvals_screen.dart
│           └── widgets/
│               ├── approval_order_card.dart
│               ├── price_discrepancy_table.dart
│               └── approval_detail_modal.dart
```

---

## 📋 3. Componentes de la Tarjeta de Aprobación (`ApprovalOrderCard`)

Cada tarjeta en el listado presenta de forma clara y concisa:
1. **Cabecera:** Folio de la orden (`FOL-2026-0842`), fecha/hora y nombre completo del paciente.
2. **Sucursal y Operador:** Nombre de la sucursal emisora y usuario de ventanilla que solicitó la orden.
3. **Motivo del Bloqueo:** Chip visual ámbar con la descripción de la discrepancia.
4. **Tabla de Precios Comparativa:**
   - Precio de Catálogo (`originalPrice`): ej. `\$850.00`.
   - Precio Aplicado (`salePriceApplied`): ej. `\$600.00`.
   - Diferencia / Descuento concedido: ej. `- \$250.00 (-29.4%)`.
5. **Acciones:**
   - Botón Secundario: **Ver Detalle Clínico**.
   - Botón Primario: **Aprobar en 1-Tap**.

---

## ⚡ 4. Flujo de Autorización en 1-Tap

```
[ Supervisor presiona "Aprobar Orden" ]
                   │
                   ▼
  [ ¿Requiere justificación obligatoria? ]
       │                               │
    (No)                             (Sí)
       │                               ▼
       │                  [ ReasonPromptDialog ]
       │                  (Ingresa motivo: ej. "Cortesía Dr. Morales")
       │                               │
       └───────────────┬───────────────┘
                       ▼
    [ ApprovalsCubit.approveOrder(orderId, reason) ]
                       │
                       ▼
  [ POST /api/v1/orders/{order_id}/approve en backend ]
                       │
                       ▼
  [ Backend valida supervisor, desmarca isBlocked = false, ]
  [ registra auditoría (approvedBy, approvedAt, reason)    ]
                       │
                       ▼
  [ WebSocket / Reactive Stream emite orden actualizada    ]
  [ La tarjeta desaparece con animación de éxito fluida     ]
```

---

## 🛡️ 5. Auditoría Inmutable

Cada aprobación registra en la orden:
- `approvedBy`: ID y nombre del supervisor autenticado en el móvil.
- `approvedAt`: Timestamp Unix en milisegundos de la aprobación.
- `approvalReason`: Texto descriptivo ingresado o asignado por defecto ("Aprobación móvil por supervisor").
