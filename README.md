# Defensa Activa en Infraestructuras Windows: Automatización de Auditorías con PowerShell y API de IA

**Proyecto Final de Ciclo Superior — ASIR 2026**
* **Autor:** Hugo López Rodríguez
* **Tutor:** Manuel Rico López
* **Centro:** C.P.R. Liceo La Paz A Coruña

## Descripción

Sistema de monitorización y detección de amenazas centralizado (SIEM ligero), desarrollado íntegramente sobre entorno Windows a coste cero. Un equipo cliente Windows 10 Pro unido al dominio `tfg.local` envía sus eventos de seguridad automáticamente a un servidor Windows Server 2022 mediante Windows Event Forwarding (WEF). 

El servidor actúa como Controlador de Dominio y colector central de eventos. Un motor desarrollado en PowerShell procesa en segundo plano los eventos críticos (Event ID 4625, 4720, etc.), los analiza semánticamente mediante la API de IA de Anthropic (Claude) y genera alertas automáticas procesadas en Telegram cuando detecta comportamientos sospechosos (intentos de fuerza bruta, creación de usuarios no autorizados o escalada de privilegios).

*Nota: Se incluye una versión alternativa del script sin dependencias de IA externa para operar de forma 100% local.*

## Tecnologías utilizadas

*   **Windows Server 2022 Standard** (Active Directory + WEF Collector)
*   **Windows 10 Pro** (Cliente del dominio)
*   **Hyper-V** (Virtualización e infraestructura de red interna)
*   **Active Directory Domain Services & GPOs**
*   **Windows Event Forwarding (WEF) & WinRM** (Suscripción Source-Initiated)
*   **PowerShell 5.1** (Motor de correlación y automatización)
*   **API de IA (Anthropic Claude - Modelo Haiku)** (Análisis semántico)
*   **Telegram Bot API** (Alertado Push)

## Estructura del repositorio

*   `/scripts` → Scripts PowerShell del sistema (`Monitor_WEF.ps1` y versión `Lite`).
*   `/config` → Archivos de configuración (`suscripcion_wef.xml`, `config.json`, `setup.bat`).
*   `/docs` → Memoria oficial del proyecto y manuales.
*   `/capturas` → Evidencias y capturas de pantalla de la configuración en laboratorio.

## Estado del proyecto

🟢 **Completado y en producción (Laboratorio)** — *Última actualización: Junio 2026*

## Infraestructura desplegada

- [x] Hyper-V configurado con dos VMs en red interna.
- [x] Windows Server 2022 Standard instalado (`TFG-Server`) — **IP: 192.160.0.10**
- [x] Windows 10 Pro instalado (`TFG-Cliente`) — **IP: 192.160.0.20**
- [x] Active Directory y dominio `tfg.local` configurado (Nivel funcional 2016).
- [x] Usuarios y grupos creados en AD jerárquicamente (`GRP_Administradores`, `GRP_Trabajadores`).
- [x] Política de auditoría forzada mediante GPO para registro de inicios de sesión fallidos.
- [x] Directiva `GPO_WEF` creada y vinculada al dominio (Permisos y WinRM).
- [x] Cliente unido exitosamente al dominio `tfg.local`.
- [x] WEF configurado (Source-Initiated) y centralizando logs en `ForwardedEvents`.
- [x] Script PowerShell optimizado para ráfagas (3000 eventos/ciclo) y persistencia en CSV local.
- [x] Integración segura (TLS 1.2) con API de Anthropic Claude y Telegram.
- [x] Automatización total del servicio mediante el Programador de Tareas (bucle de 5 minutos desatendido).

## Requisitos e Instalación

El despliegue está automatizado para entornos Windows Server. 

1. Configurar las variables de las APIs en `config.json`.
2. Ejecutar el script `setup.bat` con privilegios de Administrador para crear las rutas de logs, importar la suscripción XML y registrar la tarea programada.

Para obtener instrucciones detalladas sobre la arquitectura y la inyección de datos de prueba, consultar el **Manual del Administrador** en el directorio `/docs`.
