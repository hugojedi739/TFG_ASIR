# TFG_ASIR
Proyecto Fin ciclo Hugo Lopez
# Bastionado Windows, Centralización WEF y Alertas Inteligentes

Proyecto Final de Ciclo Superior — ASIR 2026  
Autor: Hugo Lopez

## Descripción

Sistema de monitorización y detección de amenazas centralizado, desarrollado íntegramente sobre entorno Windows.

Un equipo cliente envía sus logs de seguridad a un servidor Windows Server 2022 mediante **Windows Event Forwarding (WEF)**. Un script PowerShell analiza los eventos críticos, los procesa con una IA y genera alertas automáticas en Telegram cuando detecta comportamientos sospechosos.

## Tecnologías utilizadas

- Windows Server 2022 (Active Directory + WEF Collector)
- Windows 10/11 (cliente del dominio)
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

🟡 En desarrollo — inicio: marzo 2026

## Requisitos para reproducir el entorno

Pendiente de documentar en el Manual del Administrador.
