param(
    [string]$CarpetaFuente = 'C:\QwenTutorial\hashyy\llama.cpp',
    [ValidateRange(0,32)][int]$Gpu = 0,
    [ValidateRange(1,32)][int]$Trabajos = 6
)
. (Join-Path $PSScriptRoot 'Comun.ps1')
$card = Get-Gpu $Gpu
if ([int]$card.Arquitectura -lt 75) { throw 'Este recorrido requiere una NVIDIA RTX 20, 30, 40 o 50.' }
if (-not (Test-Path -LiteralPath (Join-Path $CarpetaFuente 'src\llama-moe-stream.cpp'))) { throw 'Primero prepara las fuentes con Preparar-Hashyy.ps1.' }
$cuda = Import-Compilador
$build = Join-Path $CarpetaFuente 'build-tutorial'
Write-Host "Compilando para $($card.Nombre), arquitectura $($card.Arquitectura)."
Invoke-Comando cmake @('-S',$CarpetaFuente,'-B',$build,'-G','Ninja','-DCMAKE_BUILD_TYPE=Release','-DGGML_CUDA=ON',"-DCMAKE_CUDA_ARCHITECTURES=$($card.Arquitectura)","-DCMAKE_CUDA_COMPILER=$cuda/bin/nvcc.exe", "-DCUDAToolkit_ROOT=$cuda",'-DLLAMA_CURL=OFF','-DLLAMA_BUILD_TESTS=OFF','-DLLAMA_BUILD_EXAMPLES=OFF','-DGGML_NATIVE=ON')
Invoke-Comando cmake @('--build',$build,'--target','llama-server','llama-bench','--parallel',"$Trabajos")
$server = Join-Path $build 'bin\llama-server.exe'
if (-not (Test-Path -LiteralPath $server)) { throw 'No se ha creado llama-server.exe.' }
Invoke-Comando $server @('--version')
Invoke-Comando $server @('--list-devices')
$helpText = & $server --help 2>&1 | Out-String
if ($LASTEXITCODE -ne 0 -or $helpText -notmatch '--moe-stream-cache') { throw 'La compilacion no incluye Expert Streaming.' }
Write-Host "Compilacion terminada: $server"
