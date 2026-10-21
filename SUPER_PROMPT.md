# 🚀 Super Prompt: Desarrollo de Serum Mobile (`serum_mobile`)

> **Rol del Agente:** Eres un **Arquitecto Senior de Software y Desarrollador Flutter/Dart de Élite**. Tu objetivo es implementar la aplicación móvil **Serum Mobile** (`serum_mobile`), diseñada específicamente para dispositivos móviles (Android, iOS) y versión Web responsiva.

---

## 🎯 1. Propósito y Filosofía de la Aplicación

**Serum Mobile** es la herramienta móvil ejecutiva, administrativa y de supervisión médica del ecosistema **Serum App** (LIS - Sistema de Información de Laboratorio Clínico).

### Audiencia Objetivo:
- Dueños de laboratorio, directores médicos, socios y administradores.
- Supervisores clínicos y auditores financieros.

### Alcance Funcional Estricto:
1. **Modo Consulta / Auditoría (Solo Lectura):**
   - **Exámenes y Órdenes Clínicas:** Consultar órdenes del día, historial de estudios solicitados y visualización clínica de resultados analíticos (valores obtenidos, rangos de referencia, flags médicos: `NORMAL`, `HIGH`, `LOW`, `ABNORMAL`).
   - **Arqueos y Turnos de Caja (`CashShift`):** Monitorear en tiempo real los turnos de caja en todas las sucursales, balances iniciales, fondos recaudados clasificados por método de pago (Efectivo, Tarjeta, Transferencia), retiros de caja chica y cortes con o sin discrepancias.
   - **Reportes Ejecutivos:** Visualizar reportes de rentabilidad financiera, volumen de pruebas procesadas, auditoría de discrepancias de turnos y médicos más remitentes.
2. **Aprobación de Órdenes Bloqueadas (`isBlocked == true`):**
   - Bandeja de entrada con badge de notificación para órdenes retenidas en ventanilla por modificación de precio o descuento especial.
   - Detalle de discrepancia: comparación ítem por ítem entre precio base de catálogo (`originalPrice`) y precio efectivamente asignado (`salePriceApplied`).
   - Flujo de autorización en 1-tap: invocación del endpoint de desbloqueo aprovechando los privilegios de sesión de supervisor (`accessLevel > 3`) o ingresando motivo de autorización.
3. **Administración y Configuración:**
   - **Gestión de Usuarios:** Consulta del directorio de usuarios activos/inactivos y **formulario de creación de nuevos usuarios** con asignación de sucursales autorizadas y rol del sistema.
   - **Ajustes del Sistema:** Visualización de parámetros institucionales (nombre, logo, datos fiscales).

> ⚠️ **LO QUE NO HACE ESTA APP (No implementar en móvil):**
> - NO es un Punto de Venta (POS): No cobra ni emite facturas/tickets impresos.
> - NO captura resultados de laboratorio: Eso lo realiza el bioanalista en la versión desktop/web de ventanilla.
> - NO edita catálogos de pruebas ni rangos de referencia.

---

## 🏗️ 2. Arquitectura Técnica y Dependencias

### Principio de Capas y Fuente Única de Verdad:
La lógica de negocio, modelos, contratos de datos, cálculo financiero en centavos y comunicación con el backend FastAPI residen íntegramente en el paquete Dart puro local `serum_business`.

### Dependencia en `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Lógica de negocio y repositorios centrales
  serum_business:
    path: ../serum_business

  # Manejo de Estado y Arquitectura Reactiva
  flutter_bloc: ^9.1.0
  get_it: ^8.0.3

  # Enrutamiento Adaptativo
  go_router: ^14.8.1

  # Almacenamiento Local Seguro (Hive CE)
  hive_ce: ^2.1.2
  hive_ce_flutter: ^2.2.0

  # UI, Iconos, Gráficos y Utilidades
  intl: ^0.20.2
  cupertino_icons: ^1.0.8
  fl_chart: ^0.70.2 # Gráficos para reportes y arqueos
```

---

## 🎨 3. Sistema de Diseño y UI/UX Móvil

### Tokens de Color (Basados en `AppColor.md`):
- **Primary:** `#006876` (Teal Clínico Oscuro) / OnPrimary: `#FFFFFF`
- **Secondary:** `#4A6267` / OnSecondary: `#FFFFFF`
- **Tertiary:** `#525E7D`
- **Background Claro:** `#FBFDFD` / Surface: `#FBFDFD`
- **Alerta / Descuadre:** `#BA1A1A` / OnError: `#FFFFFF`
- **Aprobado / Éxito:** `#1E8E3E` (Verde esmeralda médico)
- **Advertencia / Bloqueado:** `#D97706` (Ámbar intenso para badges de `isBlocked`)

### Estructura de Navegación Móvil (`ScaffoldWithNavBar`):
Utiliza `StatefulShellRoute.indexedStack` de `go_router` con una `NavigationBar` (Material 3) inferior que contiene 5 destinos ergonómicos:
1. 🏠 **Inicio (Dashboard):** Tarjetas KPI (Venta del día, órdenes totales, arqueos activos, badge animado con total de órdenes pendientes de aprobar).
2. ⚠️ **Aprobaciones:** Listado prioritario de órdenes bloqueadas con tarjetas de acción rápida (Aprobar / Ver Detalle).
3. 🩺 **Órdenes & Exámenes:** Buscador en vivo de órdenes y pacientes, con visor clínico detallado de resultados.
4. 💰 **Arqueos & Caja:** Monitor de turnos abiertos, balances por sucursal y reporte de cortes.
5. ⚙️ **Administración:** Directorio de usuarios, botón flotante `+ Nuevo Usuario` y ajustes de cuenta.

---

## 🔒 4. Reglas de Negocio Críticas a Cumplir

1. **Montos Monetarios en Centavos (`int`):**
   - Nunca usar `double` para transacciones monetarias ni balances de arqueo.
   - $150.00 se recibe y procesa como `15000`.
   - Utilizar funciones formateadoras: `(cents / 100).toStringAsFixed(2)`.

2. **Doble Token JWT y Sesión Activa:**
   - La aplicación debe inicializar la sesión con `HiveTokenStorage` (cifrado con `HiveAesCipher`).
   - El supervisor debe iniciar sesión (`authRepository.login`).
   - La aplicación debe validar que el usuario tenga rol con `accessLevel > 3` para permitirle aprobar órdenes bloqueadas o crear usuarios.

3. **Flujo de Aprobación de Órdenes (`approveOrder`):**
   - El endpoint es `POST /api/v1/orders/{order_id}/approve`.
   - Como el usuario autenticado en móvil ya es un supervisor (`accessLevel > 3`), puede aprobar enviando la solicitud directamente con su token activo o adjuntando una justificación opcional (`reason`).
   - Al aprobarse, el repositorio reactivo emite la orden actualizada y refresca la lista en tiempo real.

4. **Visualización de Resultados de Laboratorio:**
   - Interpretar el enum/string médico de cada parámetro:
     - `NORMAL`: Chip verde sutil.
     - `HIGH` / `LOW`: Chip rojo/ámbar con indicador de flecha (▲ / ▼) respecto al rango de referencia.
     - `ABNORMAL`: Chip de alerta destacada.

---

## 📂 5. Estructura de Directorios del Proyecto

Organiza el proyecto dentro de `serum_mobile/lib/` bajo la siguiente convención:

```
serum_mobile/lib/
├── config/
│   ├── app_router.dart              # GoRouter con StatefulShellRoute y guards de autenticación
│   ├── app_theme.dart               # Tema Claro y Oscuro (Material 3, ColorPalette)
│   ├── service_locator.dart         # GetIt para inyección de dependencias
│   └── app_config.dart              # Constantes de URL API y configuración
├── src/
│   ├── cubits/                      # Cubits globales de aplicación
│   │   ├── auth/                    # AuthCubit & AuthState (login, logout, checkUser)
│   │   └── pending_approvals/       # Cubit para conteo reactivo de órdenes bloqueadas
│   ├── modules/                     # Módulos de pantalla (UI)
│   │   ├── auth/                    # Pantalla de login elegante para móvil
│   │   ├── shell/                   # NavigationShell con BottomNavigationBar adaptativo
│   │   ├── dashboard/               # Métricas, KPIs y accesos directos
│   │   ├── approvals/               # Bandeja de aprobación de órdenes bloqueadas
│   │   ├── orders/                  # Consulta de órdenes y visor modal de resultados
│   │   ├── cash_shifts/             # Monitor de arqueos, turnos y cortes de caja
│   │   ├── reports/                 # Gráficos financieros y auditoría de turnos
│   │   └── admin/                   # Gestión de usuarios, diálogo de creación y settings
│   └── shared/                      # Widgets reutilizables móviles
│       ├── cards/                   # KpiCard, OrderCard, ShiftCard
│       ├── badges/                  # StatusBadge, MedicalFlagBadge
│       └── dialogs/                 # ConfirmActionDialog, ReasonPromptDialog
└── main.dart                        # Punto de entrada con Hive, ServiceLocator y ProviderContainer
```

---

## 📋 6. Plan de Ejecución Paso a Paso para el Agente

Sigue rigurosamente estos hitos de desarrollo:

### Hito 1: Setup Base e Infraestructura
1. Configurar `pubspec.yaml` con `serum_business: path: ../serum_business`, `flutter_bloc`, `go_router`, `hive_ce`, `intl`, `fl_chart`.
2. Crear `lib/config/app_theme.dart` implementando la paleta de colores de `AppColor.md`.
3. Configurar inicialización de `Hive` en `main.dart` y service locator con `SerumClient`.
4. Implementar `AuthCubit` y pantalla `LoginView`.

### Hito 2: Shell de Navegación y Dashboard
1. Implementar `AppRouter` con `StatefulShellRoute` y barra de navegación inferior (5 pestañas).
2. Construir `DashboardView` con tarjetas métricas:
   - Ventas del día (en centavos formateados).
   - Contador de órdenes activas vs completadas.
   - Alerta destacada con badge: *"X Órdenes esperando tu autorización"*.
   - Estado de turnos de caja abiertos por sucursal.

### Hito 3: Módulo de Aprobación de Órdenes Bloqueadas
1. Implementar `ApprovalsCubit` que consulte órdenes con filtro `isBlocked == true`.
2. Crear vista de listado con tarjetas que destaquen:
   - Paciente, folio y fecha.
   - Motivo del bloqueo (discrepancia de precios: catálogo vs aplicado).
   - Operador que solicitó la orden.
3. Botón de **"Aprobar Orden"** con modal de confirmación o ingreso de motivo opcional, ejecutando `ordersRepository.approveOrder()`.

### Hito 4: Módulo de Órdenes y Visor Clínico
1. Buscador en vivo de órdenes (por folio o nombre de paciente).
2. Vista de detalle de orden con visualización de:
   - Lista de estudios solicitados (individuales o Packs).
   - Resultados de parámetros ingresados con chips visuales de alerta médica (`NORMAL`, `HIGH`, `LOW`, `ABNORMAL`).

### Hito 5: Módulo de Arqueos y Turnos de Caja
1. Consultar turnos activos e históricos vía `CashShiftsRepository`.
2. Vista de arqueo con desglose por forma de pago:
   - Efectivo físico declarado vs esperado.
   - Tarjeta y Transferencias bancarias.
   - Resaltado en color rojo en caso de existir discrepancias en el corte.

### Hito 6: Módulo de Reportes Financieros
1. Integrar `ReportsRepository` con filtros de fecha (Hoy, Esta semana, Este mes).
2. Tarjetas y gráficos (`fl_chart`) para:
   - Ingresos consolidados y rentabilidad.
   - Volumen de pruebas clínicas.
   - Auditoría de turnos con descuadres.

### Hito 7: Módulo de Administración de Usuarios
1. Listado de usuarios activos con su rol y sucursales asignadas (`UsersRepository`).
2. Formulario flotante/modal móvil para **Crear Usuario**:
   - Nombre completo, username, correo, contraseña.
   - Selector de rol (`RolesRepository`).
   - Selector de sucursales permitidas (`BranchesRepository`).
   - Guardar y actualizar directorio reactivamente.

### Hito 8: Auditoría y Verificación
1. Ejecutar `flutter analyze` en `serum_mobile` y asegurar cero errores y advertencias.
2. Probar responsividad en resoluciones móviles y modo oscuro/claro.

---

> 💡 **Instrucción Final para el Agente:** Comienza leyendo `serum_business/wiki/project_index.md` para familiarizarte con todos los métodos de los repositorios y modelos antes de implementar cada vista. Escribe código modular, tipado estricto y sin `print()` en producción (usar `debugPrint` o logs de BLoC).
