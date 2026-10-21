---
type: index
title: Serum Mobile — Wiki del Proyecto
description: Índice general de la wiki de la aplicación móvil ejecutiva y de supervisión médica Serum Mobile (Flutter / Dart / serum_business).
tags: [mobile, flutter, dart, lis, index, wiki]
timestamp: 2026-10-21T16:15:00Z
---

# 📱 Serum Mobile — Wiki

Bienvenido a la documentación técnica, arquitectura y especificación funcional de la aplicación móvil **Serum Mobile**, la herramienta móvil ejecutiva, administrativa y de supervisión médica del ecosistema **Serum LIS** (Sistema de Información de Laboratorio Clínico).

---

## 🗺️ Mapa Maestro del Proyecto

| Documento | Descripción |
| :--- | :--- |
| **[Project Index (`project_index.md`)](project_index.md)** | **Mapa maestro y rector del proyecto móvil:** módulos, pantallas, cubits, widgets, flujo de capas y responsabilidades funcionales. |
| **[Instrucciones para Agentes (`AGENTS.md`)](AGENTS.md)** | Protocolo obligatorio de consulta, flujo de trabajo, uso de CLI `onion` y verificación para agentes de IA. |

---

## 📑 Secciones de Documentación

| Sección | Descripción |
| :--- | :--- |
| **[Arquitectura (`arquitectura/`)](arquitectura/INDEX.md)** | Detalles del flujo de capas (UI ➔ Cubit ➔ Repository de `serum_business`), navegación ergonómica con `StatefulShellRoute` y `NavigationBar`, e inyección de dependencias. |
| **[Módulos Funcionales (`modulos/`)](modulos/INDEX.md)** | Especificación detallada de cada pantalla móvil, tarjeta, visor clínico, diálogo y cubits asociados. |
| **[Reglas de Negocio (`reglas_negocio/`)](reglas_negocio/INDEX.md)** | Convenciones críticas: montos enteros en centavos (`int`), privilegios de supervisor (`accessLevel > 3`), doble token JWT y flags clínicos. |
