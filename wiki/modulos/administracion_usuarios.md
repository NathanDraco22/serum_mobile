---
type: module
title: Módulo — Administración y Creación de Usuarios
description: Especificación del directorio de colaboradores, consulta de roles y formulario modal móvil para creación de nuevos usuarios.
tags: [users, administration, roles, branches, crud, modal]
timestamp: 2026-10-21T16:27:00Z
---

# 👥 Administración y Creación de Usuarios

El módulo de **Administración de Usuarios** permite a los socios y directores gestionar el personal del laboratorio clínico directamente desde el dispositivo móvil, consultar el directorio institucional y **dar de alta nuevos colaboradores con sus roles y sucursales autorizadas**.

---

## 🎯 1. Objetivos del Módulo

1. **Directorio Móvil:** Listar colaboradores activos e inactivos, filtrando por sucursal, rol o búsqueda por nombre/correo.
2. **Alta Rápida de Usuarios:** Formulario modal ergonómico para registrar nuevos técnicos, recepcionistas, flebotomistas o químicos sin requerir estar en una computadora de escritorio.
3. **Asignación Segura de Permisos:** Selección de rol del sistema (`RolesRepository`) y sedes permitidas (`BranchesRepository`).

---

## 🗂️ 2. Estructura de Archivos

```
serum_mobile/lib/
├── src/
│   ├── cubits/
│   │   └── user_cubit/
│   │       ├── user_mobile_cubit.dart
│   │       └── user_mobile_state.dart
│   └── modules/
│       └── user/
│           ├── view/
│           │   └── user_screen.dart            # Directorio con FloatingActionButton '+'
│           └── widgets/
│               ├── user_card.dart              # Tarjeta de usuario con avatar y rol
│               ├── user_filter_chips.dart      # Filtros rápidos por estado y sede
│               └── user_form_modal.dart        # Formulario modal de alta de usuario
```

---

## 📝 3. Formulario Modal de Nuevo Usuario (`UserFormModal`)

El formulario se despliega como un `showModalBottomSheet` amplio o `Dialog` con validaciones reactivas:

| Campo | Tipo | Validaciones |
| :--- | :--- | :--- |
| **Nombre Completo** | `TextFormField` | Requerido, mínimo 3 caracteres. |
| **Nombre de Usuario** | `TextFormField` | Requerido, sin espacios, alfanumérico. |
| **Correo Electrónico** | `TextFormField` | Requerido, formato de correo válido. |
| **Contraseña** | `TextFormField` (obscure) | Requerido, mínimo 6 caracteres. |
| **Rol del Sistema** | `DropdownButtonFormField` | Lista obtenida dinámicamente de `RolesRepository`. |
| **Sucursales Permitidas** | `FilterChip` / Multi-select | Selección de sucursales habilitadas de `BranchesRepository`. |

---

## 🛡️ 4. Reglas de Negocio y Seguridad

- **Restricción de Creación:** Solo los usuarios con `accessLevel >= 4` (Directores / Administradores Generales) pueden crear nuevos colaboradores.
- **Inmutabilidad y Reactividad:** Tras enviar el formulario exitosamente (`UsersRepository.createUser`), el diálogo se cierra, se emite una notificación snackbar de éxito y el listado se actualiza de inmediato mediante el `ReactiveRepository`.
