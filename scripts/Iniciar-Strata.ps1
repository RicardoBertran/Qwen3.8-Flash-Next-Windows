param(
    [string]$Carpeta = 'C:\QwenTutorial\strata',
    [ValidateRange(1024,65535)][int]$Puerto = 8080
)
. (Join-Path $PSScriptRoot 'Comun.ps1')
Assert-PuertoLibre $Puerto
$app = Join-Path $Carpeta 'app'
$python = Join-Path $app '.venv\Scripts\python.exe'
$config = Join-Path $app 'strata-iq2_xs.json'
foreach ($file in @($python,$config,(Join-Path $app 'engine\strata.exe'))) {
    if (-not (Test-Path -LiteralPath $file)) { throw "Instalacion incompleta: $file" }
}
Push-Location $app
try {
    Invoke-Comando $python @('serve\server.py','--engine','strata','--config',$config,'--host','127.0.0.1','--port',"$Puerto",'--open')
} finally { Pop-Location }
