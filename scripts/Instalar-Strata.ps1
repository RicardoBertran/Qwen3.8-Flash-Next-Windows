param(
    [string]$Carpeta = 'C:\QwenTutorial\strata',
    [string]$CarpetaDatos,
    [ValidateRange(0,32)][int]$Gpu = 0,
    [ValidateRange(512,131072)][int]$Contexto = 32768,
    [ValidateRange(700,16384)][int]$ReservaMiB = 2048
)
. (Join-Path $PSScriptRoot 'Comun.ps1')
if (-not $CarpetaDatos) { $CarpetaDatos = Join-Path $Carpeta 'Strata-data' }
$card = Get-Gpu $Gpu
if ([int]$card.Arquitectura -lt 75 -or $card.VRAM -lt 12000) { throw 'El recorrido principal requiere una NVIDIA RTX con al menos 12 GB de VRAM.' }
if ([int]($card.Controlador.Split('.')[0]) -lt 580) { throw 'Actualiza el controlador NVIDIA a la version 580 o posterior.' }
$ram = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB
if ($ram -lt 46) { throw 'IQ2_XS requiere aqui 48 GB de RAM o mas. Consulta la seccion de equipos con 32 GB.' }
$app = Join-Path $Carpeta 'app'
if (-not (Test-Path -LiteralPath (Join-Path $app 'START-HERE.bat'))) { throw 'Primero ejecuta Preparar-Strata.ps1.' }
Push-Location $app
try {
    & .\START-HERE.bat --check
    $python = Join-Path $app '.venv\Scripts\python.exe'
    if (-not (Test-Path -LiteralPath $python)) { throw 'Python no se ha instalado. Consulta la guia para instalar Python 3.12 de 64 bits.' }
    Invoke-Comando $python @('setup.py','--check','--gpu',"$Gpu",'--backend','cuda')
    Invoke-Comando $python @('setup.py','--yes','--setup','--family','qwen','--model','IQ2_XS','--context',"$Contexto",'--vision','no','--gpu',"$Gpu",'--backend','cuda','--cuda','13','--vram-reserve-mib',"$ReservaMiB",'--host','127.0.0.1','--data-dir',$CarpetaDatos,'--source','huggingface','--prebuilt','https://github.com/Niko1221/Strata/releases/download/v0.1.40.2/','--no-start')
    if (-not (Test-Path -LiteralPath 'strata-iq2_xs.json')) { throw 'No se ha creado strata-iq2_xs.json.' }
    Write-Host 'Instalacion terminada. Inicia el servidor con Iniciar-Strata.ps1.'
} finally { Pop-Location }
