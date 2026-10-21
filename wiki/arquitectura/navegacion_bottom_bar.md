---
type: concept
title: Arquitectura — Navegación Móvil y Shell Adaptativo
description: Especificación de GoRouter, StatefulShellRoute, barra de navegación inferior (5 destinos), preservación de estado y guardias de seguridad.
tags: [navigation, go_router, shell, bottom_bar, guards, stateful_shell_route]
timestamp: 2026-10-21T16:19:00Z
---

# 📱 Navegación Móvil y Shell Adaptativo

La navegación en **Serum Mobile** está construida sobre `go_router` aprovechando `StatefulShellRoute.indexedStack`. Esta arquitectura garantiza navegación fluida, ergonómica para el pulgar y con **preservación de estado independiente** en cada una de las 5 secciones de la aplicación.

---

## 🗂️ 1. Estructura de Rutas y StatefulShellBranch

El enrutador (`AppRouter`) define una raíz con shell y rutas independientes:

```
/login (Ruta independiente fuera del shell)
/ (ShellRoute con StatefulNavigationShell y BottomNavigationBar)
 ├── /dashboard      (Branch 0: Inicio / KPIs / Resumen del día)
 ├── /approvals      (Branch 1: Aprobaciones de órdenes bloqueadas)
 ├── /orders         (Branch 2: Órdenes clínicas y visor de resultados)
 ├── /cash-shifts    (Branch 3: Monitor de arqueos y turnos de caja)
 └── /users          (Branch 4: Directorio y gestión de usuarios)
```

### Rutas Adicionales / Flotantes:
- `/reports`: Puede accederse desde el Dashboard o como submódulo de auditoría financiera.
- `/orders/:id`: Detalle y visor clínico en pantalla completa para visualización extendida de parámetros.

---

## 🧭 2. Los 5 Destinos del `NavigationBar` (Material 3)

La barra de navegación inferior (`src/modules/shell/widgets/bottom_nav_bar.dart`) expone 5 destinos claros:

| Índice | Etiqueta | Icono | Descripción |
| :---: | :--- | :--- | :--- |
| **0** | **Inicio** | `Icons.dashboard_rounded` | Dashboard ejecutivo con métricas de ventas, órdenes y arqueos. |
| **1** | **Aprobaciones** | `Icons.verified_user_rounded` | Bandeja prioritaria de órdenes bloqueadas (`isBlocked == true`) con badge numérico reactivo. |
| **2** | **Órdenes** | `Icons.medical_services_rounded` | Catálogo y buscador de órdenes analíticas con visor de resultados. |
| **3** | **Cajas** | `Icons.point_of_sale_rounded` | Monitor de turnos activos y cortes de caja en todas las sucursales. |
| **4** | **Usuarios** | `Icons.manage_accounts_rounded` | Directorio institucional de colaboradores y botón `+ Nuevo Usuario`. |

---

## 🛡️ 3. Guardias de Autenticación y Nivel de Acceso (`redirect`)

El router implementa una función `redirect` reactiva conectada al Stream de `AppSessionCubit`:

```dart
String? guard(BuildContext context, GoRouterState state) {
  final sessionState = context.read<AppSessionCubit>().state;
  final isLoggingIn = state.matchedLocation == '/login';

  // 1. Si no hay sesión autenticada -> Redirigir a login
  if (!sessionState.isAuthenticated) {
    return isLoggingIn ? null : '/login';
  }

  // 2. Si el usuario no tiene nivel de supervisor (accessLevel <= 3) -> Denegar acceso
  final user = sessionState.currentUser;
  if (user != null && user.accessLevel <= 3) {
    // Cerrar sesión y mostrar error de privilegio insuficiente
    return '/login?error=insufficient_permissions';
  }

  // 3. Si ya está autenticado e intenta ir a login -> Enviar al Dashboard
  if (isLoggingIn) {
    return '/dashboard';
  }

  return null;
}
```

---

## ⚡ 4. Ventajas de `StatefulShellRoute.indexedStack`

1. **Cero Pérdida de Scroll:** Si el supervisor está revisando una lista extensa de órdenes o turnos y cambia temporalmente a la pestaña de "Aprobaciones", al volver a "Órdenes" la posición del scroll y los filtros de búsqueda se mantienen intactos.
2. **Cero Re-peticiones de Red Innecesarias:** Las pantallas no se destruyen (`dispose`) ni se reconstruyen al alternar de pestaña; los Streams de los repositorios reactivos continúan actualizando el estado de fondo.
3. **Ergonomía Móvil:** Todos los accesos clave están a distancia de un tap con el pulgar.
