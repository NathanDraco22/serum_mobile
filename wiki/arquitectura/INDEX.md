---
type: index
title: Serum Mobile — Arquitectura del Sistema
description: Índice de la sección de arquitectura de Serum Mobile, detallando flujo de capas, navegación ergonómica y desacoplamiento de dependencias.
tags: [mobile, architecture, flutter, dart, layers, routing]
timestamp: 2026-10-21T16:17:00Z
---

# 🏛️ Arquitectura — Serum Mobile

Esta sección documenta las decisiones estructurales, el flujo de capas unidireccional y los patrones de diseño aplicados en la aplicación móvil **Serum Mobile**.

---

## 📑 Documentos de Arquitectura

| Documento | Descripción |
| :--- | :--- |
| **[Flujo de Capas Móvil (`flujo_de_capas_movil.md`)](flujo_de_capas_movil.md)** | Interacción entre vistas, widgets, cubits, repositorios reactivos de `serum_business`, almacenamiento Hive AES-256 y API FastAPI. |
| **[Navegación Móvil y Shell (`navegacion_bottom_bar.md`)](navegacion_bottom_bar.md)** | Implementación de `StatefulShellRoute` con `go_router`, barra `NavigationBar` de 5 pestañas, preservación de estado y guards de seguridad. |
