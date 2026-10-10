param(
    [Parameter(Mandatory=$true)][ValidateSet('hashyy','strata')][string]$Recorrido,
    [string]$Carpeta,
    [ValidateRange(1,3)][int]$Fragmento,
    [switch]$SoloVerificar
)
. (Join-Path $PSScriptRoot 'Comun.ps1')
if (-not $Carpeta) {
    if ($Recorrido -eq 'hashyy') { $Carpeta = 'C:\QwenTutorial\hashyy\modelos' }
    else { $Carpeta = 'C:\QwenTutorial\strata\Strata-data\models\IQ2_XS' }
}
$manifest = Get-Content -LiteralPath (Join-Path (Split-Path $PSScriptRoot) 'modelos.json') -Raw | ConvertFrom-Json
$model = $manifest.$Recorrido
$files = @($model.files)
if ($Fragmento) {
    if ($Fragmento -gt $files.Count) { throw 'Ese numero de fragmento no existe para este recorrido.' }
    $files = @($files[$Fragmento-1])
}
if ($SoloVerificar -and -not (Test-Path -LiteralPath $Carpeta)) { throw 'No existe la carpeta de modelos.' }
if (-not $SoloVerificar) { New-Item -ItemType Directory -Force -Path $Carpeta | Out-Null }
foreach ($file in $files) {
    $target = Join-Path $Carpeta (Split-Path $file.path -Leaf)
    if (-not (Test-Path -LiteralPath $target)) {
        if ($SoloVerificar) { throw "Falta $target" }
        if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) { throw 'Falta curl.exe. Actualiza Windows o instala curl desde https://curl.se/windows/.' }
        $part = "$target.part"
        $url = "https://huggingface.co/$($model.repo)/resolve/$($model.revision)/$($file.path)"
        Invoke-Comando curl.exe @('--fail','--location','--retry','5','--continue-at','-','--output',$part,$url)
        if ((Get-Item -LiteralPath $part).Length -ne $file.size) { throw "Tamano incorrecto: $part" }
        Write-Host "Comprobando SHA-256 de $(Split-Path $target -Leaf). Puede tardar varios minutos."
        if ((Get-FileHash -LiteralPath $part -Algorithm SHA256).Hash -ne $file.sha256) { throw "Descarga corrupta: $part. Consulta la solucion de problemas." }
        Move-Item -LiteralPath $part -Destination $target
    } else {
        if ((Get-Item -LiteralPath $target).Length -ne $file.size) { throw "Tamano incorrecto: $target" }
        Write-Host "Comprobando SHA-256 de $(Split-Path $target -Leaf). Puede tardar varios minutos."
        if ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash -ne $file.sha256) { throw "El archivo no coincide con el modelo del tutorial: $target" }
    }
    Write-Host "Correcto: $target"
}
