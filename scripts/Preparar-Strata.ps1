param([string]$Carpeta = 'C:\QwenTutorial\strata')
. (Join-Path $PSScriptRoot 'Comun.ps1')
$app = Join-Path $Carpeta 'app'
$commit = 'e8ca9afd03d839d4f8dbbe82dffce7f8a3bafd7a'
if (Test-Path -LiteralPath $app) { throw 'La carpeta app ya existe. Continua con Instalar-Strata.ps1 o elige otra carpeta para empezar desde cero.' }
New-Item -ItemType Directory -Force -Path $Carpeta | Out-Null
$zip = Join-Path $Carpeta 'strata-fuentes.zip'
$temp = Join-Path $Carpeta 'fuentes-extraidas'
if (Test-Path -LiteralPath $temp) { throw 'Ya existe fuentes-extraidas. Elige otra carpeta o revisa la instalacion anterior.' }
Invoke-WebRequest -UseBasicParsing "https://github.com/Niko1221/Strata/archive/$commit.zip" -OutFile $zip
if ((Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash -ne '9E5A8086FC1869C6A23859BD9D06E93D91ADBC066B54C4239F84A70F791E4480') {
    throw 'La descarga de fuentes no coincide con el archivo comprobado del tutorial. No se extraera.'
}
Expand-Archive -LiteralPath $zip -DestinationPath $temp
Move-Item -LiteralPath (Join-Path $temp "Strata-$commit") -Destination $app
Write-Host "Strata preparado: $app"
Write-Host 'El siguiente paso comprobara el equipo e instalara Python si falta.'
