---
type: index
title: Serum Mobile — Mapa del Proyecto (Project Index)
description: Mapa maestro y exhaustivo de la arquitectura de Serum Mobile (Flutter), módulos de pantalla, cubits, widgets, navegación ergonómica y flujo de capas con serum_business.
tags: [mobile, flutter, dart, bloc, cubit, index, map, lis]
timestamp: 2026-10-21T16:16:00Z
---

# 🗺️ Project Index — Serum Mobile (Flutter & LIS Ejecutivo)

Este documento constituye el **mapa central y rector** de la aplicación móvil **Serum Mobile** (`serum_mobile`). Cualquier agente o desarrollador que trabaje en la interfaz de usuario, navegación, manejo de estados, cubits o integración de datos DEBE utilizar este índice para comprender la arquitectura, ubicar los componentes adecuados y respetar el flujo de capas establecido.

---

## 🎯 1. Propósito y Filosofía de la Aplicación

**Serum Mobile** es la herramienta móvil ejecutiva, administrativa y de supervisión médica del ecosistema **Serum LIS** (Sistema de Información de Laboratorio Clínico).

### Audiencia Objetivo:
- Dueños de laboratorio, directores médicos, administradores y socios.
- Supervisores clínicos y auditores financieros.

### Alcance Funcional Estricto:
1. **Modo Consulta y Auditoría (Solo Lectura):**
   - **Exámenes y Órdenes Clínicas:** Consultar órdenes del día, historial de estudios solicitados y visualización clínica de resultados analíticos (valores obtenidos, rangos de referencia, flags médicos: `NORMAL`, `HIGH`, `LOW`, `ABNORMAL`).
   - **Arqueos y Turnos de Caja (`CashShift`):** Monitorear en tiempo real los turnos de caja en todas las sucursales, balances iniciales, fondos recaudados clasificados por método de pago (Efectivo, Tarjeta, Transferencia), retiros de caja chica y cortes con o sin discrepancias.
   - **Reportes Ejecutivos:** Visualizar métricas de rentabilidad financiera, volumen de pruebas procesadas, auditoría de discrepancias de turnos y médicos remitentes.
2. **Aprobación de Órdenes Bloqueadas (`isBlocked == true`):**
   - Bandeja de entrada con badge de notificación para órdenes retenidas en ventanilla por modificación de precio o descuento especial.
   - Detalle de discrepancia: comparación ítem por ítem entre precio base de catálogo (`originalPrice`) y precio efectivamente asignado (`salePriceApplied`).
   - Flujo de autorización en 1-tap: invocación del endpoint de desbloqueo aprovechando los privilegios de sesión de supervisor (`accessLevel > 3`) o ingresando motivo de autorización opcional.
3. **Administración y Configuración:**
   - **Gestión de Usuarios:** Consulta del directorio de colaboradores activos/inactivos y formulario de creación de nuevos usuarios con asignación de sucursales autorizadas y rol del sistema.
   - **Ajustes del Sistema:** Visualización de parámetros institucionales (nombre, logo, datos fiscales).

> ⚠️ **LO QUE NO HACE ESTA APP (Límites de Alcance Móvil):**
> - **NO es un Punto de Venta (POS):** No cobra en mostrador ni emite facturas/tickets impresos.
> - **NO captura resultados de laboratorio:** Eso lo realiza el bioanalista en la versión desktop/web de ventanilla.
> - **NO edita catálogos de pruebas ni rangos de referencia.**

---

## 🏛️ 2. Arquitectura General y Flujo de Capas

Serum Mobile consume íntegramente la lógica de negocio, modelos, contratos de datos y persistencia del paquete local Dart puro `serum_business`.

```
[ Vista Móvil (UI / Widgets / Diálogos) ]
                   ↓ Invoca métodos / Escucha estados
[ Capa de Estado (BLoC / Cubit: AppSession, Approvals, Order, etc.) ]
                   ↓ Consulta o muta
[ Capa de Repositorios (Repositories reactivos en serum_business) ]
                   ↓ Consume y mapea
[ Capa de Fuentes de Datos (DataSources en serum_business) ]
                   ↓ Emite peticiones HTTP o persistencia
[ Capa de Infraestructura (HttpService / HiveTokenStorage con AES-256) ]
```

---

## 📦 3. Árbol de Directorios del Proyecto

```
serum_mobile/
├── lib/
│   ├── config/                         # Configuración transversal
│   │   ├── app_router.dart             # GoRouter con StatefulShellRoute y guards de autenticación
│   │   ├── app_theme.dart              # Temas Claro/Oscuro (Material 3, ColorPalette de AppColor.md)
│   │   ├── service_locator.dart        # Inyección de dependencias con GetIt
│   │   ├── app_serum_config.dart       # Implementación de SerumClientConfig
│   │   └── app_assets.dart             # Rutas a logotipos e iconos
│   ├── material_app_builder.dart       # Builder desacoplado con MediaQuery textScaler clamp
│   ├── provider_container.dart         # MultiRepositoryProvider (SerumClient) y GlobalCubitProvider
│   ├── main.dart                       # Punto de entrada conciso (MyApp y AppRoot)
│   └── src/
│       ├── core/                       # Utilidades de configuración móvil
│       │   └── app_config_manager.dart # Manager de preferencias locales
│       ├── cubits/                     # Cubits de alcance de vista y sesión
│       │   ├── app_session_cubit/      # Sesión de usuario activo y sucursal
│       │   ├── approvals_cubit/        # Consulta y aprobación de órdenes retenidas
│       │   ├── order_cubit/            # Búsqueda y visor clínico de órdenes
│       │   ├── cash_shift_cubit/       # Monitor de arqueos y turnos de caja
│       │   ├── report_cubit/           # Métricas financieras y auditorías
│       │   └── user_cubit/             # Directorio y creación de usuarios
│       ├── modules/                    # Módulos de interfaz organizados en view/ y widgets/
│       │   ├── auth/                   # Pantalla de Login móvil
│       │   │   ├── view/login_screen.dart
│       │   │   └── widgets/login_card.dart
│       │   ├── shell/                  # Shell con BottomNavigationBar adaptativo (5 pestañas)
│       │   │   ├── view/shell_screen.dart
│       │   │   └── widgets/bottom_nav_bar.dart
│       │   ├── dashboard/              # Métricas, KPIs y accesos directos
│       │   │   ├── view/dashboard_screen.dart
│       │   │   └── widgets/kpi_grid.dart, pending_approvals_banner.dart
│       │   ├── approvals/              # Bandeja de órdenes bloqueadas (isBlocked == true)
│       │   │   ├── view/approvals_screen.dart
│       │   │   └── widgets/approval_order_card.dart, price_discrepancy_table.dart
│       │   ├── order/                  # Consulta de órdenes y visor de resultados
│       │   │   ├── view/order_screen.dart
│       │   │   └── widgets/order_card.dart, order_results_modal.dart
│       │   ├── cash_shift/             # Monitor de arqueos, turnos y cortes
│       │   │   ├── view/cash_shift_screen.dart
│       │   │   └── widgets/shift_breakdown_card.dart, discrepancy_badge.dart
│       │   ├── report/                 # Gráficos ejecutivos con fl_chart
│       │   │   ├── view/report_screen.dart
│       │   │   └── widgets/financial_kpi_card.dart, revenue_bar_chart.dart
│       │   └── user/                   # Directorio y registro de usuarios
│       │       ├── view/user_screen.dart
│       │       └── widgets/user_card.dart, user_form_modal.dart
│       ├── tools/                      # Formateadores y calculadoras
│       │   ├── formatters/             # Formateo de centavos a moneda, fechas, folios
│       │   └── calculators/            # Agregaciones de totales y porcentajes
│       └── widgets/                    # Widgets transversales (NO usar carpeta 'shared')
│           ├── common/                 # Botones, badges de estado, loaders
│           │   ├── kpi_card.dart
│           │   ├── status_badge.dart
│           │   └── medical_flag_badge.dart
│           └── dialogs/                # Modales de confirmación
│               ├── confirm_action_dialog.dart
│               └── reason_prompt_dialog.dart
└── wiki/                               # Esta Wiki dedicada
    ├── project_index.md                # ESTE ARCHIVO (Mapa rector de Serum Mobile)
    ├── AGENTS.md                       # Protocolo obligatorio para agentes IA
    ├── INDEX.md                        # Índice de navegación OKF
    ├── arquitectura/                   # Arquitectura de capas, navegación y dependencias
    ├── modulos/                        # Documentación funcional detallada por módulo
    └── reglas_negocio/                 # Reglas de negocio críticas (centavos, roles, JWT)
```

---

## 📱 4. Catálogo de Módulos de Pantalla

| Módulo | Ruta | Descripción Funcional |
| :--- | :--- | :--- |
| **Auth** | `/login` | Autenticación mediante credenciales con validación de nivel de supervisor (`accessLevel > 3`). |
| **Shell** | `/` (Base) | Contenedor principal con `NavigationBar` ergonómica de 5 pestañas manteniendo estados con `StatefulShellRoute`. |
| **Dashboard** | `/dashboard` | Resumen ejecutivo del día: ingresos en centavos, órdenes activas, turnos abiertos y banner animado de aprobaciones pendientes. |
| **Aprobaciones** | `/approvals` | Bandeja prioritaria de órdenes bloqueadas por modificación de precio. Muestra discrepancia ítem por ítem y botón de aprobación en 1-tap. |
| **Órdenes** | `/orders` | Buscador de estudios por folio y paciente, con visor modal de resultados analíticos categorizados por flags médicos. |
| **Arqueos** | `/cash-shifts` | Monitor en vivo de turnos en sucursales, balances por método de pago (Efectivo, Tarjeta, Transferencia) y alertas de descuadre. |
| **Reportes** | `/reports` | Gráficos con `fl_chart` de ingresos, desglose financiero, volumen de pruebas y auditoría de discrepancias. |
| **Usuarios** | `/users` | Directorio de personal activo e inactivo con botón flotante para crear nuevos usuarios con sucursal y rol. |

---

## 🧠 5. Catálogo de Cubits y Manejo de Estado

| Cubit | Ubicación | Responsabilidad |
| :--- | :--- | :--- |
| **`AppSessionCubit`** | `src/cubits/app_session_cubit/` | Maneja la sesión del usuario autenticado, hidratación inicial con JWT y datos del supervisor. |
| **`ApprovalsCubit`** | `src/cubits/approvals_cubit/` | Consulta y filtra órdenes con `isBlocked == true`, ejecuta el desbloqueo mediante `approveOrder`. |
| **`OrderMobileCubit`** | `src/cubits/order_cubit/` | Búsqueda reactiva de órdenes y visualización de snapshots clínicos con resultados. |
| **`CashShiftMobileCubit`** | `src/cubits/cash_shift_cubit/` | Monitor de turnos de caja en sucursales, balances esperados vs declarados. |
| **`ReportMobileCubit`** | `src/cubits/report_cubit/` | Agregación de métricas de ingresos, pruebas y auditoría financiera por rangos de fecha. |
| **`UserMobileCubit`** | `src/cubits/user_cubit/` | Listado de colaboradores, consulta de roles/sucursales y alta de nuevos usuarios. |

---

## 🧩 6. Componentes Reutilizables y Diálogos

1. **`KpiCard` (`src/widgets/common/kpi_card.dart`):** Tarjeta con icono, métrica formateada, indicador de tendencia o etiqueta de estado.
2. **`MedicalFlagBadge` (`src/widgets/common/medical_flag_badge.dart`):** Chip visual con código de colores según el estado clínico:
   - `NORMAL`: Verde esmeralda sutil.
   - `HIGH` / `LOW`: Rojo/ámbar con flechas indicadoras (▲ / ▼).
   - `ABNORMAL`: Púrpura/ámbar destacado.
3. **`StatusBadge` (`src/widgets/common/status_badge.dart`):** Badge de estado operativo para órdenes (`PENDING`, `IN_PROCESS`, `COMPLETED`, `CANCELLED`).
4. **`ReasonPromptDialog` (`src/widgets/dialogs/reason_prompt_dialog.dart`):** Modal para capturar la justificación opcional de autorización de una orden bloqueada.
5. **`ConfirmActionDialog` (`src/widgets/dialogs/confirm_action_dialog.dart`):** Diálogo universal de confirmación (aprobar, activar/desactivar).

---

## 🔗 7. Integración con `serum_business`

Serum Mobile inyecta los siguientes repositorios provistos por `SerumClient`:
- **`AuthRepository`**: Inicio de sesión, validación de JWT y cierre de sesión.
- **`OrdersRepository`**: Stream de órdenes (`watchOrders`), búsqueda y método `approveOrder(orderId, reason)`.
- **`CashShiftsRepository`**: Consulta de turnos abiertos e históricos en todas las sedes.
- **`ReportsRepository`**: Extracción de analíticas financieras y de volumen.
- **`UsersRepository`**, **`RolesRepository`**, **`BranchesRepository`**: Administración de personal y control de acceso.

---

## 🔒 8. Reglas de Negocio Críticas

1. **Montos Monetarios en Centavos (`int`):**
   - Todos los precios, saldos, importes y diferencias se manejan en centavos enteros (`int`).
   - Jamás se utiliza `double` para transacciones monetarias.
   - Formateo estándar en UI: `(cents / 100).toStringAsFixed(2)`.
2. **Nivel de Acceso de Supervisor (`accessLevel > 3`):**
   - El acceso a Serum Mobile requiere rol de supervisor, administrador o socio (`accessLevel > 3`).
   - Si un usuario con nivel de acceso $\le 3$ (ej. cajero o recepcionista) intenta iniciar sesión, la aplicación rechaza el acceso informando que debe utilizar la terminal de ventanilla.
3. **Flujo de Aprobación de Órdenes:**
   - Una orden con `isBlocked == true` no puede imprimirse ni pasar a resultados en ventanilla sin aprobación previa.
   - El supervisor autoriza la orden mediante `POST /api/v1/orders/{order_id}/approve`.
   - La lista de órdenes se actualiza de inmediato mediante reactividad de Streams.
