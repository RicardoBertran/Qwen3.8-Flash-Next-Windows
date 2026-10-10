Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Invoke-Comando {
    param([string]$Programa, [string[]]$Argumentos)
    & $Programa @Argumentos
    if ($LASTEXITCODE -ne 0) { throw "Ha fallado $Programa (codigo $LASTEXITCODE). Corrige el error antes de continuar." }
}

function Get-Gpu {
    param([int]$Indice)
    if (-not (Get-Command nvidia-smi -ErrorAction SilentlyContinue)) {
        throw 'Falta el controlador NVIDIA. Instala el controlador y reinicia Windows.'
    }
    $rows = & nvidia-smi --query-gpu=index,name,uuid,compute_cap,memory.total,driver_version --format=csv,noheader,nounits
    if ($LASTEXITCODE -ne 0) { throw 'No se han podido consultar las GPU.' }
    foreach ($row in $rows) {
        $v = $row.Split(',') | ForEach-Object { $_.Trim() }
        if ([int]$v[0] -eq $Indice) {
            return [pscustomobject]@{Indice=$Indice; Nombre=$v[1]; UUID=$v[2]; Arquitectura=$v[3].Replace('.',''); VRAM=[int]$v[4]; Controlador=$v[5]}
        }
    }
    throw "No existe la GPU $Indice. Consulta nvidia-smi para elegir el numero correcto."
}

function Import-Compilador {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    if (-not (Test-Path -LiteralPath $vswhere)) { throw 'Faltan Visual Studio Build Tools 2022 y las herramientas de C++.' }
    $vs = & $vswhere -products '*' -version '[17.0,18.0)' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath -latest
    if (-not $vs) { throw 'No se encuentra Visual Studio 2022 con el compilador de C++.' }
    $vcvars = Join-Path $vs 'VC\Auxiliary\Build\vcvars64.bat'
    $lines = & $env:ComSpec /d /c "call `"$vcvars`" >nul && set"
    if ($LASTEXITCODE -ne 0) { throw 'No se ha podido activar el compilador de C++.' }
    foreach ($line in $lines) {
        if ($line -match '^([^=]+)=(.*)$') { [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process') }
    }
    $ninjaDir = Join-Path $vs 'Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja'
    if (-not (Get-Command ninja -ErrorAction SilentlyContinue)) { $env:PATH = "$ninjaDir;$env:PATH" }
    foreach ($tool in @('cmake','ninja','cl')) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { throw "Falta $tool. Revisa el paso de dependencias." }
    }
    $cuda = Join-Path $env:ProgramFiles 'NVIDIA GPU Computing Toolkit\CUDA\v13.4'
    if (-not (Test-Path -LiteralPath (Join-Path $cuda 'bin\nvcc.exe'))) { throw 'Falta CUDA Toolkit 13.4.' }
    $env:CUDA_PATH = $cuda
    $env:CUDAToolkit_ROOT = $cuda
    $env:PATH = "$cuda\bin\x64;$cuda\bin;$env:PATH"
    return $cuda
}

function Assert-PuertoLibre {
    param([int]$Puerto)
    if (Get-NetTCPConnection -LocalPort $Puerto -State Listen -ErrorAction SilentlyContinue) {
        throw "El puerto $Puerto ya esta ocupado. Cierra el servidor anterior o elige otro puerto."
    }
}
