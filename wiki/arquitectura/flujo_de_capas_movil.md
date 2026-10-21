---
type: concept
title: Arquitectura — Flujo de Capas Móvil y Gestión de Estado
description: Detalle del flujo unidireccional de datos en Serum Mobile, desacoplamiento con ProviderContainer y consumo reactivo de serum_business.
tags: [architecture, layers, cubit, bloc, reactive, repository, data_flow]
timestamp: 2026-10-21T16:18:00Z
---

# 🏛️ Flujo de Capas Móvil y Gestión de Estado

La arquitectura de **Serum Mobile** implementa una separación estricta de responsabilidades bajo un flujo unidireccional de datos, desacoplando la interfaz de usuario de las reglas de negocio y la infraestructura de red.

---

## 🔄 1. Diagrama de Flujo Unidireccional

```
┌──────────────────────────────────────────────────────────────┐
│                    VISTA MÓVIL (UI)                          │
│  (Screens en lib/src/modules/*/view/ y widgets/ locales)     │
└───────────────────────────────┬──────────────────────────────┘
                                │ Invoca métodos o escucha estados
                                ▼
┌──────────────────────────────────────────────────────────────┐
│                   CAPA DE ESTADO (CUBIT)                     │
│  (lib/src/cubits/*: AppSession, Approvals, Orders, Shifts)   │
└───────────────────────────────┬──────────────────────────────┘
                                │ Consulta / Muta entidades
                                ▼
┌──────────────────────────────────────────────────────────────┐
│             REPOSITORIOS (serum_business)                    │
│  (ReactiveRepository con BehaviorSubject y caché en memoria) │
└───────────────────────────────┬──────────────────────────────┘
                                │ Mapea DTOs a Modelos fuertemente tipados
                                ▼
┌──────────────────────────────────────────────────────────────┐
│            FUENTES DE DATOS (serum_business)                 │
│  (DataSources: HttpService con token JWT y endpoints REST)   │
└───────────────────────────────┬──────────────────────────────┘
                                │ Petición HTTPS (JSON)
                                ▼
┌──────────────────────────────────────────────────────────────┐
│               BACKEND REST (FastAPI / MongoDB)               │
└──────────────────────────────────────────────────────────────┘
```

---

## 🧩 2. Responsabilidades por Capa

### 1. Vista Móvil (`lib/src/modules/` y `lib/src/widgets/`):
- Renderiza componentes adaptativos y ergonómicos para pantallas táctiles.
- Dispara eventos al Cubit correspondiente mediante `context.read<MiCubit>().metodo()`.
- Reacciona a cambios de estado mediante `BlocBuilder`, `BlocConsumer` o `BlocListener`.
- **Regla Estricta:** Las vistas nunca consumen repositorios directamente ni realizan cálculos financieros complejos; delegan siempre al Cubit o a formateadores de `lib/src/tools/`.

### 2. Capa de Cubit / BLoC (`lib/src/cubits/`):
- Modela y emite estados inmutables (`Initial`, `Loading`, `Success`, `Error`).
- Consume los repositorios de `serum_business` inyectados a través de `RepositoryProvider` o GetIt.
- Maneja suscripciones a Streams emitidos por los repositorios reactivos para actualizar la UI en tiempo real.

### 3. Repositorios (`serum_business/lib/src/domain/repositories/`):
- Implementan el patrón `ReactiveRepository` manteniendo el estado local sincronizado sin necesidad de recargar la pantalla manualmente.
- Validan transiciones de datos y emiten eventos reactivos en el bus de la aplicación.

### 4. Fuentes de Datos y Clientes HTTP (`serum_business/lib/src/data/`):
- Encapsulan las llamadas a los endpoints REST del backend FastAPI (`/api/v1/...`).
- Aplican automáticamente el token Bearer JWT recuperado de `HiveTokenStorage`.
- Desempaquetan respuestas JSON y gestionan errores HTTP.

---

## 💉 3. Inicialización e Inyección Desacoplada

Para evitar sobrecargar `main.dart`, Serum Mobile replica el patrón modular de `serum_app_front`:

1. **`main.dart`**: Punto de entrada conciso. Inicializa Flutter, Hive CE y levanta `MyApp`.
2. **`provider_container.dart`**:
   - `ProviderContainer`: Encapsula `MultiRepositoryProvider` con la instancia de `SerumClient` (que provee los 20 repositorios).
   - `GlobalCubitProvider`: Provee a nivel de raíz los cubits transversales (`AppSessionCubit`).
3. **`material_app_builder.dart`**:
   - Builder global que envuelve `MaterialApp.router` controlando el escalado de tipografía con `MediaQuery` y `textScaler.clamp` para evitar roturas visuales en pantallas de alta densidad.
4. **`config/service_locator.dart`**:
   - Registro de servicios con `GetIt` para acceso rápido y desacoplado fuera del árbol de widgets.
