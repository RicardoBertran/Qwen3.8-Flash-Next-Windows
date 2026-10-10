param([string]$Carpeta = 'C:\QwenTutorial\hashyy')
. (Join-Path $PSScriptRoot 'Comun.ps1')
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Instala Git y abre una nueva ventana de PowerShell.' }
$Carpeta = [IO.Path]::GetFullPath($Carpeta)
$hashyy = Join-Path $Carpeta 'hashyy-original'
$source = Join-Path $Carpeta 'llama.cpp'
$base = '254b177307b14d055bbe4c050c9c441a1e06d8a4'
$patch = Join-Path (Split-Path $PSScriptRoot) 'patches\hashyy-expert-streaming.patch'
if ((Get-FileHash -LiteralPath $patch -Algorithm SHA256).Hash -ne '190D0CC8CFEAA0C5067D842683EC58B695ACDC49BC802515334B6F65DD82E94B') { throw 'El parche no coincide con la version del tutorial.' }
if (Test-Path -LiteralPath $source) { throw 'La carpeta llama.cpp ya existe. Para compilar de nuevo usa Compilar-Hashyy.ps1; para empezar desde cero elige otra carpeta.' }
New-Item -ItemType Directory -Force -Path $Carpeta | Out-Null
if (-not (Test-Path -LiteralPath $hashyy)) {
    Invoke-Comando git @('init',$hashyy)
    Invoke-Comando git @('-C',$hashyy,'remote','add','origin','https://github.com/MohammadHaishemKhawaja/hashyy.git')
    Invoke-Comando git @('-C',$hashyy,'fetch','--depth','1','origin','6189bf3746e6bc267465c66d85cc07ebd8dde79a')
    Invoke-Comando git @('-C',$hashyy,'checkout','--detach','FETCH_HEAD')
}
Invoke-Comando git @('init',$source)
Invoke-Comando git @('-C',$source,'config','core.longpaths','true')
Invoke-Comando git @('-C',$source,'config','core.autocrlf','false')
Invoke-Comando git @('-C',$source,'remote','add','origin','https://github.com/ggml-org/llama.cpp.git')
Invoke-Comando git @('-C',$source,'fetch','--depth','1','origin',$base)
Invoke-Comando git @('-C',$source,'checkout','--detach','FETCH_HEAD')
Invoke-Comando git @('-C',$source,'apply','--check',$patch)
Invoke-Comando git @('-C',$source,'apply',$patch)
Invoke-Comando git @('-C',$source,'diff','--check')
Write-Host "Fuentes listas: $source"
