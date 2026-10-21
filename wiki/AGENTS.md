# AGENTS.md — Instrucciones Obligatorias para Agentes de IA (Serum Mobile)

Este archivo establece las directrices que **todo agente de IA o desarrollador DEBE cumplir estrictamente** antes de analizar, planificar o realizar cambios en la aplicación móvil `serum_mobile`.

---

## 🚨 Regla de Oro: Consulta Obligatoria de `project_index.md`

**Antes de proponer cualquier cambio de código, responder preguntas de arquitectura o modificar cualquier archivo en `serum_mobile`:**

1. **Consulta `project_index.md` como mapa rector**:
   Debes leer [project_index.md](project_index.md) para ubicar en qué módulo, capa, vista o cubit reside la funcionalidad requerida, cuáles son sus widgets asociados y cómo interactúan con los repositorios de `serum_business`.

2. **Revisión del Documento Rector de Requerimientos**:
   Consulta [SUPER_PROMPT.md](../SUPER_PROMPT.md) para verificar el alcance funcional estricto de la aplicación móvil (supervisión ejecutiva, aprobación de órdenes, arqueos, reportes y gestión de usuarios).

3. **Verificación de Módulos Funcionales**:
   Antes de editar pantallas, tarjetas o cubits, revisa la sección del módulo correspondiente en [modulos/](modulos/INDEX.md):
   - Flujo de sesión y guardias de supervisor: Lee [modulos/auth_y_sesion.md](modulos/auth_y_sesion.md).
   - Métricas y dashboard ejecutivo: Lee [modulos/dashboard_kpis.md](modulos/dashboard_kpis.md).
   - Aprobación de órdenes retenidas: Lee [modulos/aprobacion_ordenes.md](modulos/aprobacion_ordenes.md).
   - Visor clínico de resultados: Lee [modulos/ordenes_y_visor_clinico.md](modulos/ordenes_y_visor_clinico.md).
   - Monitor de turnos y arqueos: Lee [modulos/arqueos_y_turnos_caja.md](modulos/arqueos_y_turnos_caja.md).
   - Reportes ejecutivos: Lee [modulos/reportes_ejecutivos.md](modulos/reportes_ejecutivos.md).
   - Directorio y creación de usuarios: Lee [modulos/administracion_usuarios.md](modulos/administracion_usuarios.md).

4. **Límites de Alcance (Lo que NO hace Serum Mobile)**:
   - ❌ NO es un Punto de Venta (POS): No cobra ni emite tickets impresos.
   - ❌ NO captura resultados de laboratorio de ventanilla.
   - ❌ NO edita catálogos de pruebas ni rangos de referencia.

---

## 🛠️ Normas de Trabajo y Comandos CLI `onion`

> 🚨 **REGLA FUNDAMENTAL DE GENERACIÓN DE CÓDIGO:**
> **No crees archivos manualmente si existe un comando `onion` que los genere.**
> El entorno cuenta con el CLI `onion` preinstalado. Siempre debes generar las estructuras base utilizando el CLI y luego adaptar el código a los requerimientos móviles específicos.

Comandos principales de `onion`:
- Generar Módulo Flutter Completo (Cubit, Dialogs, View, Widgets):
  ```powershell
  onion flutter-module <entity> --output-dir lib/src/modules/ --reactive
  ```
- Generar Vistas Específicas:
  ```powershell
  onion dart-view <entity> --output-dir lib/src/modules/<entity>/view/
  ```
- Generar Cubits:
  ```powershell
  onion dart-cubit <entity> --output-dir lib/src/cubits/<entity>/
  ```
- Generar Barrels (`export.dart`):
  ```powershell
  onion barrel <directory_path>
  ```

---

## 🔒 Convenciones Técnicas Críticas

1. **Montos Monetarios en Centavos (`int`):**
   - Nunca usar `double` para transacciones monetarias ni balances de arqueo.
   - Formatear siempre con `(cents / 100).toStringAsFixed(2)`.
2. **Doble Token JWT y Sesión Activa:**
   - La aplicación debe inicializar la sesión con `HiveTokenStorage` (cifrado con `HiveAesCipher`).
   - La aplicación debe validar que el usuario tenga rol con `accessLevel > 3` para permitirle aprobar órdenes bloqueadas o crear usuarios.
3. **Flujo de Capas Unidireccional:**
   - UI (View/Widgets) ➔ Cubit ➔ Repository de `serum_business` ➔ DataSource ➔ Backend.
   - Jamás realizar llamadas HTTP directas desde widgets o cubits móviles.

---

## 🧪 Verificación Posterior a Cambios de Código

Tras modificar cualquier archivo en `serum_mobile`, ejecuta siempre el análisis estático asegurando cero errores y advertencias:

```powershell
flutter analyze
```
