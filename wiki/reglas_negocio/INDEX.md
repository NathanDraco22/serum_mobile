---
type: index
title: Serum Mobile — Reglas de Negocio
description: Índice de las reglas de negocio y restricciones críticas aplicables a la aplicación móvil Serum Mobile.
tags: [mobile, business_rules, cents, supervisor, security, index]
timestamp: 2026-10-21T16:28:00Z
---

# ⚖️ Reglas de Negocio — Serum Mobile

Esta sección compila las restricciones operativas, financieras y de seguridad obligatorias que rigen el comportamiento de **Serum Mobile**.

---

## 📑 Reglas Documentadas

| Documento | Descripción |
| :--- | :--- |
| **[Montos Monetarios en Centavos (`montos_en_centavos.md`)](montos_en_centavos.md)** | Tratamiento monetario estricto en enteros (`int`), formateo visual a decimales y prohibición de números de coma flotante (`double`) en cálculos financieros. |
| **[Privilegios y Auditoría de Supervisión (`privilegios_supervisor.md`)](privilegios_supervisor.md)** | Restricciones por nivel de acceso (`accessLevel > 3`), guardias de sesión, aprobación de descuentos y trazabilidad inmutable de acciones. |
