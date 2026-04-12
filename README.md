# Bastionado Windows, Centralización WEF y Alertas Inteligentes

Proyecto Final de Ciclo Superior — ASIR 2026 
Autor: Hugo Lopez

## Descripción

Sistema de monitorización y detección de amenazas centralizado, desarrollado íntegramente sobre entorno Windows.

Un equipo cliente envía sus logs de seguridad a un servidor Windows Server 2022 mediante **Windows Event Forwarding (WEF)**. Un script PowerShell analiza los eventos críticos, los procesa con una IA y genera alertas automáticas en Telegram cuando detecta comportamientos sospechosos.

## Tecnologías utilizadas

- Windows Server 2022 (Active Directory + WEF Collector)
- Windows 10 Pro (cliente del dominio)
- Hyper-V (virtualización)
- Windows Event Forwarding (WEF)
- PowerShell
- API de IA (Claude / OpenAI)
- Telegram Bot API

## Estructura del repositorio
```
/scripts        → Scripts PowerShell del sistema
/docs           → Memoria del proyecto
/capturas       → Capturas de pantalla de la configuración
```

## Estado del proyecto

🟡 En desarrollo — última actualización: abril 2026
## Infraestructura desplegada

- ✅ Hyper-V configurado con dos VMs
- ✅ Windows Server 2022 instalado (TFG-Server)
- ✅ Active Directory y dominio tfg.local configurado
- ✅ Usuarios y grupos creados en AD
- ✅ Política de auditoría configurada
- ✅ Windows 10 Pro instalado (TFG-Cliente)
- ✅ Cliente unido al dominio tfg.local
- ⏳ WEF — pendiente
- ⏳ Script PowerShell — pendiente
- ⏳ Integración IA + Telegram — pendiente

## Requisitos para reproducir el entorno

Pendiente de documentar en el Manual del Administrador.
