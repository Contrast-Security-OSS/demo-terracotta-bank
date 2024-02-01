# Function to stop processes listening on a port
function Stop-ProcessOnPort {
    param (
        [int]$Port
    )
    $processes = Get-NetTCPConnection -State Listen | Where-Object { $_.LocalPort -eq $Port } | Get-Process
    if ($processes) {
        $processes | Stop-Process -Force
        Write-Host "Stopped processes on port $Port."
    } else {
        Write-Host "No process found on port $Port."
    }
}

# Stop the development server
$devPort = 8080
Stop-ProcessOnPort -Port $devPort

# Stop the production server
$prodPort = 8082
Stop-ProcessOnPort -Port $prodPort
