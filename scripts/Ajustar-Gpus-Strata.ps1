param(
    [string]$Carpeta = 'C:\QwenTutorial\strata',
    [Parameter(Mandatory=$true)][ValidatePattern('^\d+(,\d+)*$')][string]$Gpus,
    [ValidateRange(700,16384)][int]$ReservaPrimeraMiB = 2048,
    [ValidateRange(700,16384)][int]$ReservaOtrasMiB = 3072
)
. (Join-Path $PSScriptRoot 'Comun.ps1')
$indices = @($Gpus.Split(',') | ForEach-Object { [int]$_ })
if (@($indices | Select-Object -Unique).Count -ne $indices.Count) { throw 'No repitas una GPU en la lista.' }
foreach ($index in $indices) {
    $card = Get-Gpu $index
    if ([int]$card.Arquitectura -lt 75 -or $card.VRAM -lt 8000) { throw "GPU ${index}: requiere una RTX con al menos 8 GB para este reparto." }
    Write-Host "GPU $index : $($card.Nombre)"
}
$path = Join-Path $Carpeta 'app\strata-iq2_xs.json'
if (-not (Test-Path -LiteralPath $path)) { throw 'Primero instala Strata IQ2_XS.' }
$cfg = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
$cfg | Add-Member -NotePropertyName gpu -NotePropertyValue $indices -Force
$cfg | Add-Member -NotePropertyName gpus_asked -NotePropertyValue $true -Force
$cfg | Add-Member -NotePropertyName layer_split -NotePropertyValue 'auto' -Force
$list = New-Object 'System.Collections.Generic.List[string]'
foreach ($arg in $cfg.args) { $list.Add([string]$arg) }
foreach ($flag in @('--vram-reserve-mib','--vram-reserve-later-mib')) {
    while ($list.Contains($flag)) {
        $i = $list.IndexOf($flag)
        if ($i+1 -ge $list.Count) { throw "La configuracion tiene una opcion incompleta: $flag" }
        $list.RemoveAt($i+1)
        $list.RemoveAt($i)
    }
}
$list.Add('--vram-reserve-mib'); $list.Add([string]$ReservaPrimeraMiB)
$list.Add('--vram-reserve-later-mib'); $list.Add([string]$ReservaOtrasMiB)
$cfg.args = @($list.ToArray())
$backup = "$path.$(Get-Date -Format 'yyyyMMdd-HHmmss-fff').bak"
Copy-Item -LiteralPath $path -Destination $backup
$json = $cfg | ConvertTo-Json -Depth 12
[IO.File]::WriteAllText($path,$json,(New-Object Text.UTF8Encoding($false)))
Write-Host "Configuracion guardada. Copia anterior: $backup"
Write-Host 'Inicia de nuevo Strata para aplicar el reparto.'
