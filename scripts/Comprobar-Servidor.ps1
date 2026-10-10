param(
    [Parameter(Mandatory=$true)][ValidateSet('hashyy','strata')][string]$Recorrido,
    [ValidateRange(1024,65535)][int]$Puerto,
    [ValidateRange(30,3600)][int]$EsperaSegundos = 600
)
. (Join-Path $PSScriptRoot 'Comun.ps1')
if (-not $Puerto) { if ($Recorrido -eq 'hashyy') { $Puerto=8099 } else { $Puerto=8080 } }
$url = "http://127.0.0.1:$Puerto"
$deadline = (Get-Date).AddSeconds($EsperaSegundos)
$ready = $false
while ((Get-Date) -lt $deadline) {
    try {
        $health = Invoke-RestMethod "$url/health" -TimeoutSec 5
        if ($health.status -eq 'ok' -and ($Recorrido -ne 'strata' -or $health.loaded -eq $true)) { $ready=$true; break }
    } catch { }
    Start-Sleep -Seconds 3
}
if (-not $ready) { throw 'El modelo no ha terminado de cargar. Revisa la ventana del servidor y el apartado de problemas.' }
$models = Invoke-RestMethod "$url/v1/models" -TimeoutSec 15
if (-not $models.data -or -not $models.data[0].id) { throw 'El servidor no devuelve un modelo.' }
$body = @{
    model=$models.data[0].id
    messages=@(@{role='user';content='Responde en una frase: cuanto es dos mas dos?'})
    max_tokens=256
    temperature=0
    stream=$false
    chat_template_kwargs=@{enable_thinking=$false}
    reasoning_effort='none'
} | ConvertTo-Json -Depth 8
$answer = Invoke-RestMethod "$url/v1/chat/completions" -Method Post -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 600
if (-not $answer.choices -or -not $answer.choices[0].message.content) { throw 'El servidor respondio, pero no genero texto visible.' }
Write-Host "Modelo cargado: $($models.data[0].id)"
Write-Host "Respuesta: $($answer.choices[0].message.content)"
Write-Host "Puedes abrir $url en el navegador."
