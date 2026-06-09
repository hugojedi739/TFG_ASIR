[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# VARIABLES GLOBALES Y CREDENCIALES

$ApiKey = "API" 
$ApiUrl = "https://api.anthropic.com/v1/messages"

# Credenciales del BotFather (Telegram)
$TelegramToken = ""
$TelegramChatId = ""

# Configuración de lectura WEF
$LogName = "ForwardedEvents" 
# Leemos de 200 en 200 para no saturar la RAM del servidor virtual
$MaxEventos = 3000 
$RutaCSV = "C:\Scripts\alertas.csv"

# Array con los Event IDs que nos interesa vigilar (Fuerza bruta, grupos admin, etc.)
$EventosCriticos = @(4625, 4720, 4728, 4732, 4756, 4648, 4719, 4964)


# FUNCIONES DE CONEXIÓN A APIS EXTERNAS

function Invoke-AnalisisIA {
    param([string]$TextoEvento)
    
    # IMPORTANTE: Cambia el nombre de abajo por el que veas en tu seccion 'Limits'
    $NombreModelo = "claude-haiku-4-5-20251001"

    $BodyData = @{
        model = $NombreModelo
        max_tokens = 250
        messages = @(
            @{
                role = "user"
                content = "Eres un asistente de seguridad. Analiza este evento y responde en español pero SIN usar tildes ni caracteres especiales (sin acentos, sin enyes). Usa este formato exacto:

SEVERIDAD: CRITICO/ALTO/MEDIO/BAJO
CAUSA: (una sola linea)
RECOMENDACION: (una sola linea)
INTERVENCION HUMANA: SI/NO

Evento: $TextoEvento"
            }
        )
    }

    $JsonString = $BodyData | ConvertTo-Json -Depth 10
    $JsonBytes = [System.Text.Encoding]::UTF8.GetBytes($JsonString)

    try {
        $Respuesta = Invoke-RestMethod -Uri $ApiUrl -Method POST -Headers @{
            "x-api-key" = $ApiKey
            "anthropic-version" = "2023-06-01"
        } -ContentType "application/json; charset=utf-8" -Body $JsonBytes
        
        return $Respuesta.content[0].text
    } catch {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        return "ERROR_FINAL: " + $reader.ReadToEnd()
    }
}

function Send-AlertaTelegram {
    param([string]$Mensaje)
    
    $TelegramUrl = "https://api.telegram.org/bot$TelegramToken/sendMessage"
    
    # Limpiamos el mensaje de caracteres especiales para evitar problemas de encoding
    $MensajeLimpio = $Mensaje -replace '[áàäâ]','a' -replace '[éèëê]','e' -replace '[íìïî]','i' -replace '[óòöô]','o' -replace '[úùüû]','u' -replace '[ÁÀÄÂ]','A' -replace '[ÉÈËÊ]','E' -replace '[ÍÌÏÎ]','I' -replace '[ÓÒÖÔ]','O' -replace '[ÚÙÜÛ]','U' -replace '[ñ]','n' -replace '[Ñ]','N'

    $BodyObj = @{
        chat_id = $TelegramChatId
        text    = $MensajeLimpio
    }
    $BodyJson = [System.Text.Encoding]::UTF8.GetString(
        [System.Text.Encoding]::UTF8.GetBytes(
            ($BodyObj | ConvertTo-Json -Compress)
        )
    )

    try {
        Invoke-RestMethod -Uri $TelegramUrl -Method Post `
            -ContentType "application/json; charset=utf-8" `
            -Body ([System.Text.Encoding]::UTF8.GetBytes($BodyJson)) | Out-Null
    } catch {
        Write-Host "[!] Error al enviar mensaje a Telegram." -ForegroundColor Red
    }
}


# LECTURA DE EVENTOS Y FILTRADO BASE 

Write-Host "[*] Iniciando monitorización WEF..." -ForegroundColor Cyan
Write-Host "[*] Consultando últimos $MaxEventos eventos del canal $LogName..." -ForegroundColor Cyan

# SilentlyContinue evita letras rojas feas si el registro está vacío
$Eventos = Get-WinEvent -LogName $LogName -MaxEvents $MaxEventos -ErrorAction SilentlyContinue

if ($Eventos -eq $null) {
    Write-Host "[i] El canal de eventos está vacío actualmente." -ForegroundColor Yellow
    exit
}

# Filtramos usando el array de IDs
$EventosFiltrados = $Eventos | Where-Object { $EventosCriticos -contains $_.Id }

if ($EventosFiltrados.Count -eq 0) {
    Write-Host "[+] No se han detectado eventos críticos en esta pasada." -ForegroundColor Green
} else {
    Write-Host "[!] Se han encontrado $($EventosFiltrados.Count) eventos sospechosos." -ForegroundColor Red
}


# MOTOR DE DETECCION ATAQUE DE FUERZA BRUTA

# Si hay logins fallidos (4625), los analizamos
$LoginsFallidos = $EventosFiltrados | Where-Object { $_.Id -eq 4625 }

if ($LoginsFallidos) {
    Write-Host "`n[>>>] Iniciando módulo de análisis de Fuerza Bruta..." -ForegroundColor Cyan
    
    # Agrupamos por nombre de usuario (Propiedad 5 del log de Windows)
    $Agrupados = $LoginsFallidos | Group-Object { 
        try { $_.Properties[5].Value } catch { "Usuario_Desconocido" }
    } | Where-Object { $_.Count -ge 3 } # Umbral de 3 intentos para considerarlo ataque

    if ($Agrupados.Count -eq 0) {
        Write-Host "[+] Logins fallidos detectados, pero no superan el umbral de alerta (Falsos positivos)." -ForegroundColor Green
    } else {
        foreach ($Grupo in $Agrupados) {
            Write-Host "[!] ALERTA: Patrón de fuerza bruta detectado contra la cuenta: $($Grupo.Name)" -ForegroundColor Red
            Write-Host "[i] Intentos registrados: $($Grupo.Count)" -ForegroundColor Yellow
            
            # Sintetizamos la info para gastar menos tokens en la IA
            $TextoParaIA = "El usuario $($Grupo.Name) ha acumulado $($Grupo.Count) intentos fallidos de inicio de sesión consecutivos (Event ID 4625) desde un equipo origen en el dominio."
            
            Write-Host "[*] Procesando semántica con Claude AI..." -ForegroundColor Cyan
            $Analisis = Invoke-AnalisisIA -TextoEvento $TextoParaIA
            
            Write-Host "[*] Emitiendo notificación push vía Telegram..." -ForegroundColor Cyan
            Send-AlertaTelegram -Mensaje $Analisis
            
            Write-Host "[+] Notificación enviada con éxito." -ForegroundColor Green
        }
    }
}


# EXPORTAR HISTORIAL A CSV

if ($EventosFiltrados.Count -gt 0) {
    # Comprobamos si el fichero existe para crear la cabecera o simplemente añadir
    if (-not (Test-Path $RutaCSV)) {
        "Fecha,EventID,Equipo,Usuario,Descripcion,TipoAlerta" | Out-File $RutaCSV -Encoding UTF8
    }

    foreach ($Evento in $EventosFiltrados) {
        $Fecha = $Evento.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
        $EventID = $Evento.Id
        $Equipo = $Evento.MachineName
        $Usuario = try { $Evento.Properties[5].Value } catch { "Desconocido" }
        
        # Limpieza intensiva de saltos de línea y comas para no romper el CSV
        $MensajeRaw = if ($Evento.Message) { $Evento.Message } else { "Log sin descripción" }
        $Descripcion = $MensajeRaw.Substring(0, [Math]::Min(100, $MensajeRaw.Length)) -replace "`r`n"," " -replace "`n"," " -replace "`r"," " -replace ","," "
        
        $TipoAlerta = switch ($EventID) {
            4625 { "Login fallido" }
            4720 { "Usuario creado" }
            4728 { "Escalada privilegios admin" }
            4648 { "Uso de credenciales explícitas" }
            4719 { "Modificación política auditoría" }
            default { "Evento crítico genérico" }
        }
        
        "$Fecha,$EventID,$Equipo,$Usuario,$Descripcion,$TipoAlerta" | Out-File $RutaCSV -Append -Encoding UTF8
    }
    Write-Host "`nHistorial actualizado localmente en: $RutaCSV" -ForegroundColor Cyan
}
