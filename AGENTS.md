# AGENTS.md — Serum Mobile (Flutter / Dart)

> [!IMPORTANT]
> **CONSULTA PREVIA OBLIGATORIA DEL PROJECT INDEX**:
> Antes de analizar, planificar o realizar cambios en `serum_mobile`, **DEBES consultar el mapa maestro en [`wiki/project_index.md`](wiki/project_index.md)**, las especificaciones en [`wiki/modulos/`](wiki/modulos/INDEX.md) y el requerimiento de negocio rector en [`SUPER_PROMPT.md`](SUPER_PROMPT.md).

---

## 🎯 1. Propósito y Alcance de Serum Mobile

Serum Mobile es la herramienta ejecutiva y de supervisión médica del ecosistema Serum LIS.
- **Enfoque:** Monitoreo gerencial, auditoría de turnos de caja y arqueos, visor clínico de órdenes analíticas, autorización de órdenes retenidas (`isBlocked == true`) y gestión de usuarios.
- **Lo que NO hace:** NO es un Punto de Venta (POS), NO cobra ni emite tickets impresos, NO captura resultados de banco de laboratorio y NO edita el catálogo de pruebas.

---

## 🛠️ 2. Comandos CLI Obligatorios (`onion`)

> 🚨 **No crees archivos manualmente si existe un comando `onion` que los genere.**

*   `onion flutter-module <entity> --output-dir lib/src/modules/ --reactive`: Genera módulo UI completo con `cubit/`, `dialog/`, `view/` y `widgets/`.
*   `onion dart-view <entity> --output-dir lib/src/modules/<entity>/view/`: Genera vista base.
*   `onion dart-cubit <entity> --output-dir lib/src/cubits/<entity>/`: Genera BLoCs/Cubits.
*   `onion barrel <directory>`: Genera archivo barrel (`export.dart`).

---

## 🏛️ 3. Arquitectura y Capas

1. **Lógica Central:** Reside en `serum_business` (repositorios reactivos, modelos tipados y llamadas HTTP).
2. **Capa Móvil (`serum_mobile/lib/`):**
   - `config/`: Enrutamiento con `go_router` (`StatefulShellRoute`), tema visual Material 3 y `service_locator.dart`.
   - `src/cubits/`: Cubits especializados de la UI (`AppSessionCubit`, `ApprovalsCubit`, `OrderMobileCubit`, etc.).
   - `src/modules/`: Módulos de interfaz organizados en `view/` y `widgets/`.
   - `src/widgets/`: Componentes transversales (`kpi_card`, `medical_flag_badge`, `dialogs/`).

---

## 🔒 4. Convenciones Críticas

*   **Montos en centavos (`int`):** Formatear siempre con `(cents / 100).toStringAsFixed(2)`.
*   **Permisos de Supervisor:** Exigir `accessLevel > 3` para aprobar órdenes o crear usuarios.
*   **Análisis estático:** Ejecutar siempre `flutter analyze` tras cualquier modificación.
