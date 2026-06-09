# Defensa Activa en Infraestructuras Windows: Automatización de Auditorías con PowerShell y API de IA

**Proyecto Final de Ciclo Superior — ASIR 2026**
* **Autor:** Hugo López Rodríguez
* **Tutor:** Manuel Rico López
* **Centro:** C.P.R. Liceo "La Paz" — A Coruña

## Descripción

Este proyecto es un sistema de monitorización y detección de amenazas centralizado (un SIEM ligero), desarrollado íntegramente sobre un entorno Windows y a coste cero. Funciona de la siguiente manera: un equipo cliente (Windows 10 Pro) unido al dominio `tfg.local` envía sus eventos de seguridad de forma automática a un servidor Windows Server 2022 utilizando Windows Event Forwarding (WEF). 

En el servidor, que actúa como Controlador de Dominio y colector central, un motor que he desarrollado en PowerShell procesa en segundo plano los eventos críticos (como el Event ID 4625 o 4720). El sistema analiza esta información semánticamente a través de la API de IA de Anthropic (Claude) y te envía una alerta automática por Telegram en cuanto detecta comportamientos sospechosos (intentos de fuerza bruta, creación de cuentas no autorizadas o escalada de privilegios).

*Nota: Se incluye una versión alternativa del script que funciona sin dependencias de IA externa, pensada para operar de forma 100% local.*

## Tecnologías utilizadas

*   **Windows Server 2022 Standard** (Active Directory + WEF Collector)
*   **Windows 10 Pro** (Cliente del dominio)
*   **Hyper-V** (Virtualización e infraestructura de red interna)
*   **Active Directory Domain Services & GPOs**
*   **Windows Event Forwarding (WEF) & WinRM** (Suscripción Source-Initiated)
*   **PowerShell 5.1** (Motor de correlación y automatización)
*   **API de IA (Anthropic Claude - Modelo Haiku)** (Análisis semántico)
*   **Telegram Bot API** (Alertas push)

## Estructura del repositorio

*   `/scripts` → Scripts en PowerShell del sistema (`Monitor_WEF.ps1` y su versión `Lite`).
*   `/config` → Archivos de configuración necesarios (`suscripcion_wef.xml`, `config.json`, `setup.bat`).
*   `/docs` → Memoria oficial del proyecto y manuales.
*   `/capturas` → Evidencias y capturas de pantalla del entorno de laboratorio.

## Estado del proyecto

🟢 **Completado y en producción (Laboratorio)** — *Última actualización: Junio 2026*

## Infraestructura desplegada

- [x] Entorno virtualizado en Hyper-V con dos VMs conectadas en red interna.
- [x] Servidor Windows Server 2022 Standard (`TFG-Server`) — **IP: 192.160.0.10**
- [x] Equipo Windows 10 Pro (`TFG-Cliente`) — **IP: 192.160.0.20**
- [x] Active Directory y dominio `tfg.local` operativos (Nivel funcional 2016).
- [x] Estructura de usuarios y grupos en AD (`GRP_Administradores`, `GRP_Trabajadores`).
- [x] Política de auditoría (GPO) forzada para registrar inicios de sesión fallidos.
- [x] Directiva `GPO_WEF` desplegada en el dominio para gestionar permisos y WinRM.
- [x] Cliente correctamente unido al dominio `tfg.local`.
- [x] Servicio WEF (Source-Initiated) capturando logs centralizados en `ForwardedEvents`.
- [x] Script en PowerShell optimizado para manejar ráfagas (3000 eventos/ciclo) y guardar el histórico en CSV local.
- [x] Integración segura (TLS 1.2) con las APIs de Anthropic Claude y Telegram.
- [x] Automatización total del servicio mediante el Programador de Tareas (bucle de 5 minutos desatendido).

## Requisitos e Instalación

El despliegue está preparado para automatizarse fácilmente en entornos Windows Server:

1. Configura las variables de las APIs en el archivo `config.json`.
2. Ejecuta el script `setup.bat` con privilegios de Administrador. Esto creará las rutas de los logs, importará la suscripción XML y registrará la tarea programada.

Para obtener instrucciones más detalladas sobre la arquitectura y cómo inyectar datos de prueba, puedes consultar el **Manual del Administrador** dentro de la carpeta `/docs`
