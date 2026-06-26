param (
    [Parameter(Mandatory=$true)]
    [string]$Url
)

Write-Host "Iniciando simulador de trafico HTTP contra $Url ..."
Write-Host "Presiona Ctrl+C para detener."

# Crear un runspace pool para realizar peticiones concurrentes
$pool = [runspacefactory]::CreateRunspacePool(1, 100)
$pool.Open()

$threads = @()

for ($i = 0; $i -lt 500; $i++) {
    $powershell = [powershell]::Create().AddScript({
        param($targetUrl)
        try {
            $response = Invoke-WebRequest -Uri $targetUrl -UseBasicParsing -TimeoutSec 5
            return $response.StatusCode
        } catch {
            return $_.Exception.Message
        }
    }).AddArgument($Url)

    $powershell.RunspacePool = $pool
    $threads += [PSCustomObject]@{
        Runspace = $powershell
        Handle = $powershell.BeginInvoke()
    }
}

Write-Host "Peticiones en proceso..."

while ($true) {
    # Infinite loop to keep traffic going
    try {
        Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 3 > $null
    } catch {
    }
}
