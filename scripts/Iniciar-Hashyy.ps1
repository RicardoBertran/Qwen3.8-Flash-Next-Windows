param(
    [string]$Carpeta = 'C:\QwenTutorial\hashyy',
    [string]$CarpetaModelos,
    [ValidateRange(0,32)][int]$Gpu = 0,
    [ValidateRange(1,128)][int]$CacheGiB = 4,
    [ValidateRange(512,131072)][int]$Contexto = 4096,
    [ValidateRange(1024,65535)][int]$Puerto = 8099
)
. (Join-Path $PSScriptRoot 'Comun.ps1')
$card = Get-Gpu $Gpu
Assert-PuertoLibre $Puerto
if (-not $CarpetaModelos) { $CarpetaModelos = Join-Path $Carpeta 'modelos' }
$manifest = (Get-Content -LiteralPath (Join-Path (Split-Path $PSScriptRoot) 'modelos.json') -Raw | ConvertFrom-Json).hashyy
foreach ($file in $manifest.files) {
    $path = Join-Path $CarpetaModelos (Split-Path $file.path -Leaf)
    if (-not (Test-Path -LiteralPath $path)) { throw "Falta el fragmento $path" }
    if ((Get-Item -LiteralPath $path).Length -ne $file.size) { throw "Fragmento incompleto: $path" }
}
$server = Join-Path $Carpeta 'llama.cpp\build-tutorial\bin\llama-server.exe'
if (-not (Test-Path -LiteralPath $server)) { throw 'Primero compila hashyy con Compilar-Hashyy.ps1.' }
$cuda = Join-Path $env:ProgramFiles 'NVIDIA GPU Computing Toolkit\CUDA\v13.4'
if (-not (Test-Path -LiteralPath $cuda)) { throw 'Falta CUDA Toolkit 13.4.' }
$saved = @{}
foreach ($key in @('PATH','CUDA_VISIBLE_DEVICES','LLAMA_MOE_STREAM_KEEP_MMAP','LLAMA_MOE_STREAM_HOT','LLAMA_MOE_STREAM_HEAT','LLAMA_MOE_STREAM_ONE_HANDLE')) { $saved[$key] = [Environment]::GetEnvironmentVariable($key,'Process') }
try {
    $env:PATH = "$cuda\bin\x64;$cuda\bin;$env:PATH"
    $env:CUDA_VISIBLE_DEVICES = $card.UUID
    $env:LLAMA_MOE_STREAM_KEEP_MMAP = '1'
    $env:LLAMA_MOE_STREAM_HOT = $null
    $env:LLAMA_MOE_STREAM_HEAT = $null
    $env:LLAMA_MOE_STREAM_ONE_HANDLE = $null
    $model = Join-Path $CarpetaModelos (Split-Path $manifest.files[0].path -Leaf)
    Write-Host "GPU $Gpu : $($card.Nombre). Abre http://127.0.0.1:$Puerto cuando termine la carga."
    Invoke-Comando $server @('-m',$model,'--moe-stream-cache',"$CacheGiB",'--moe-stream-io-threads','4','--poll','0','-ngl','99','-fa','on','-ctk','q8_0','-ctv','q8_0','-ub','128','-c',"$Contexto",'-np','1','--jinja','--host','127.0.0.1','--port',"$Puerto")
} finally {
    foreach ($key in $saved.Keys) { [Environment]::SetEnvironmentVariable($key,$saved[$key],'Process') }
}
