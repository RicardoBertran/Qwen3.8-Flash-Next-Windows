. (Join-Path $PSScriptRoot 'Comun.ps1')
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { throw 'Instala Instalador de aplicaciones desde Microsoft Store y abre una nueva ventana de PowerShell. Consulta la guia.' }
$packages = @(
    @{Id='Git.Git'; Version=$null},
    @{Id='Kitware.CMake'; Version='4.4.4'},
    @{Id='Microsoft.VisualStudio.2022.BuildTools'; Version='17.14.41'},
    @{Id='Nvidia.CUDA'; Version='13.4'}
)
foreach ($package in $packages) {
    Write-Host "Instalando o comprobando $($package.Id)..."
    $argsList = @('install','--exact','--id',$package.Id,'--source','winget','--accept-package-agreements','--accept-source-agreements')
    if ($package.Version) { $argsList += @('--version',$package.Version) }
    if ($package.Id -eq 'Microsoft.VisualStudio.2022.BuildTools') {
        $argsList += @('--override','--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended')
    }
    & winget @argsList
    # WinGet: paquete instalado sin actualizacion disponible; instalador: reinicio pendiente.
    if ($LASTEXITCODE -notin @(0,3010,1641,-1978335189)) { throw "No se ha podido instalar $($package.Id). Codigo $LASTEXITCODE. Consulta la guia." }
    if ($LASTEXITCODE -in @(3010,1641)) { throw 'La instalacion necesita reiniciar Windows. Reinicia y vuelve a ejecutar este paso.' }
}
Write-Host 'Cierra PowerShell y abre una nueva ventana antes de preparar las fuentes.'
