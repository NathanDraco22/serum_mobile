---
type: module
title: Módulo — Autenticación y Sesión Móvil
description: Especificación de la pantalla de login, validación de credenciales, control de acceso por nivel de supervisor y ciclo de vida de la sesión.
tags: [auth, session, login, jwt, access_level, supervisor]
timestamp: 2026-10-21T16:21:00Z
---

# 🔐 Autenticación y Sesión Móvil

El módulo de **Autenticación** gestiona el acceso seguro a **Serum Mobile**, garantizando que únicamente usuarios autorizados con rol de supervisión o administración puedan ingresar al sistema.

---

## 🎯 1. Propósito y Reglas de Acceso

- **Público Objetivo:** Directores, socios, administradores de sucursal y supervisores médicos.
- **Validación de Privilegios:** Solo se permite el acceso a usuarios con **`accessLevel > 3`**.
- Si un usuario con `accessLevel <= 3` (cajeros, técnicos de ventanilla) intenta ingresar:
  1. La aplicación invalida los tokens de sesión.
  2. Muestra un mensaje de advertencia claro: *"Acceso restringido: Esta aplicación es de uso exclusivo para supervisores y directores médicos. Por favor ingresa desde la terminal de ventanilla."*

---

## 🗂️ 2. Estructura de Archivos

```
serum_mobile/lib/
├── src/
│   ├── cubits/
│   │   └── app_session_cubit/
│   │       ├── app_session_cubit.dart
│   │       └── app_session_state.dart
│   └── modules/
│       └── auth/
│           ├── view/
│           │   └── login_screen.dart
│           └── widgets/
│               ├── login_header.dart
│               └── login_form_card.dart
```

---

## 🔄 3. Ciclo de Vida y Flujo de Autenticación

```
[ Usuario ingresa credenciales (username/password) ]
                         │
                         ▼
             [ AppSessionCubit.login() ]
                         │
                         ▼
        [ AuthRepository.login() en serum_business ]
                         │
         ┌───────────────┴───────────────┐
         ▼                               ▼
    (Falla 401/403)               (Éxito: Tokens emitidos)
   Emite LoginFailure                    │
                                         ▼
                            [ Valida user.accessLevel > 3 ]
                                         │
                         ┌───────────────┴───────────────┐
                         ▼                               ▼
                   (accessLevel > 3)              (accessLevel <= 3)
                   Emite Authenticated           Llama AuthRepository.logout()
                   Navega a /dashboard            Emite UnauthorizedSupervisor
```

---

## 🔒 4. Persistencia Segura y Doble Token

- Los tokens `access_token` y `refresh_token` se almacenan en `HiveTokenStorage` utilizando cifrado simétrico **AES-256** (`HiveAesCipher`).
- Al abrir la aplicación, `AppSessionCubit.initSession()` verifica si existe un token persistido válido, ejecuta `checkUser()` en el backend para validar que el usuario siga activo y recupera su perfil completo sin requerir reingreso de contraseña.
