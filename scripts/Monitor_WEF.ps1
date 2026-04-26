# Canal donde llegan los eventos del cliente y cuantos eventos leemos de golpe
$LogName = "ForwardedEvents" 
$MaxEventos = 200

# ID de eventos que consideramos peligrosos
# 4625=login fallido, 4720=usuario creado, 4728=añadido a grupo admin
# 4648=login con credenciales explícitas, 4719=cambio política auditoría
$EventosCriticos = @(4625, 4720, 4728, 4732, 4756, 4648, 4719, 4964)

# Leer eventos del canal ForwardedEvents
Write-Host "Leyendo eventos de $LogName..." -ForegroundColor Cyan
$Eventos = Get-WinEvent -LogName $LogName -MaxEvents $MaxEventos -ErrorAction SilentlyContinue

if ($Eventos -eq $null) {
    Write-Host "No hay eventos en $LogName" -ForegroundColor Yellow
    exit
}

Write-Host "Total eventos leídos: $($Eventos.Count)" -ForegroundColor Green

# Filtramos solo los que nos interesan
$EventosFiltrados = $Eventos | Where-Object { $EventosCriticos -contains $_.Id }
Write-Host "Eventos críticos encontrados: $($EventosFiltrados.Count)" -ForegroundColor Red

# Mostramos el detalle de cada uno
foreach ($Evento in $EventosFiltrados) {
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    Write-Host "Event ID : $($Evento.Id)" -ForegroundColor Red
    Write-Host "Fecha    : $($Evento.TimeCreated)" -ForegroundColor White
    Write-Host "Equipo   : $($Evento.MachineName)" -ForegroundColor White
    Write-Host "Detalle  : $($Evento.Message.Substring(0, [Math]::Min(150, $Evento.Message.Length)))" -ForegroundColor White
}

# Detección de fuerza bruta
# Si un usuario tiene más de 3 intentos fallidos seguidos, es sospechoso
Write-Host "`n=== ANÁLISIS DE FUERZA BRUTA ===" -ForegroundColor Cyan

$LoginsFallidos = $EventosFiltrados | Where-Object { $_.Id -eq 4625 }

$Agrupados = $LoginsFallidos | Group-Object { 
    try { $_.Properties[5].Value } catch { "Desconocido" }
} | Where-Object { $_.Count -ge 3 }

if ($Agrupados.Count -eq 0) {
    Write-Host "No se detectaron patrones de fuerza bruta" -ForegroundColor Green
} else {
    foreach ($Grupo in $Agrupados) {
        Write-Host "ADVERTECIA: POSIBLE FUERZA BRUTA detectada:" -ForegroundColor Red
        Write-Host "Usuario: $($Grupo.Name)" -ForegroundColor Yellow
        Write-Host "Intentos fallidos: $($Grupo.Count)" -ForegroundColor Yellow
    }
}

# Guardar alertas en CSV para tener historial
# El archivo se crea en: C:\Scripts\alertas.csv
$RutaCSV = "C:\Scripts\alertas.csv"

# Si no existe el CSV lo creamos con cabeceras
if (-not (Test-Path $RutaCSV)) {
    "Fecha,EventID,Equipo,Usuario,Descripcion,TipoAlerta" | Out-File $RutaCSV -Encoding UTF8
}

# Guardamos cada evento crítico en el CSV
foreach ($Evento in $EventosFiltrados) {
    $Fecha = $Evento.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
    $EventID = $Evento.Id
    $Equipo = $Evento.MachineName
    $Usuario = try { $Evento.Properties[5].Value } catch { "Desconocido" }
    
    # Comprobamos que el mensaje no sea null antes de procesarlo
    $MensajeRaw = if ($Evento.Message) { $Evento.Message } else { "Sin descripcion" }
    $Descripcion = $MensajeRaw.Substring(0, [Math]::Min(100, $MensajeRaw.Length)) -replace "`r`n"," " -replace "`n"," " -replace "`r"," " -replace ","," "
    
    # Determinar tipo de alerta según Event ID
    $TipoAlerta = switch ($EventID) {
        4625 { "Login fallido" }
        4720 { "Usuario creado" }
        4728 { "Añadido a grupo admin" }
        4648 { "Credenciales explícitas" }
        4719 { "Cambio política auditoría" }
        default { "Evento crítico" }
    }
    
    "$Fecha,$EventID,$Equipo,$Usuario,$Descripcion,$TipoAlerta" | Out-File $RutaCSV -Append -Encoding UTF8
}

Write-Host "`nAlertas guardadas en $RutaCSV" -ForegroundColor Cyan
