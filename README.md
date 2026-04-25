# Bastionado Windows, Centralización WEF y Alertas Inteligentes

Proyecto Final de Ciclo Superior — ASIR 2026  
Autor: Hugo López Rodríguez  
Tutor: Manuel Rico López  
Centro: C.P.R. Liceo "La Paz" — A Coruña

---

## Descripción

Sistema de monitorización y detección de amenazas centralizado, desarrollado íntegramente sobre entorno Windows.
Un equipo cliente Windows 10 Pro unido al dominio tfg.local envía sus eventos de seguridad automáticamente a un servidor Windows Server 2022 mediante **Windows Event Forwarding (WEF)**. El servidor actúa como Controlador de Dominio y colector central de eventos.
Un script PowerShell (en desarrollo) analizará los eventos críticos, los procesará con una API de IA y generará alertas automáticas en Telegram cuando detecte comportamientos sospechosos como intentos de fuerza bruta, creación de usuarios no autorizados o escalada de privilegios.
---

## Tecnologías utilizadas

- Windows Server 2022 Datacenter Evaluation (Active Directory + WEF Collector)
- Windows 10 Pro (cliente del dominio)
- Hyper-V (virtualización)
- Active Directory Domain Services
- Windows Event Forwarding (WEF)
- PowerShell
- API de IA (Claude/OpenAI)
- Telegram Bot API

---

## Estructura del repositorio
```
/scripts        → Scripts PowerShell del sistema
/docs           → Memoria del proyecto
/capturas       → Capturas de pantalla de la configuración
```
---
## Estado del proyecto

🟡 En desarrollo — última actualización: abril 2026

## Infraestructura desplegada

- ✅ Hyper-V configurado con dos VMs
- ✅ Windows Server 2022 instalado (TFG-Server) — IP: 192.168.0.10
- ✅ Windows 10 Pro instalado (TFG-Cliente) — IP: 192.168.0.20
- ✅ Active Directory y dominio tfg.local configurado
- ✅ Usuarios y grupos creados en AD (GRP_Administradores, GRP_Trabajadores)
- ✅ Política de auditoría configurada en Default Domain Policy
- ✅ GPO_WEF creada y vinculada al dominio
- ✅ Cliente unido al dominio tfg.local
- ✅ WEF configurado y funcionando — eventos reenviados verificados
- ⏳ Script PowerShell de análisis — pendiente
- ⏳ Integración API IA — pendiente
- ⏳ Bot de Telegram — pendiente

---

## Requisitos para reproducir el entorno

Pendiente de documentar en el Manual del Administrador.
