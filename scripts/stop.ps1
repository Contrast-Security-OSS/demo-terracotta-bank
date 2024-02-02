# Function to stop processes listening on a port
function Stop-ProcessOnPort {
    param (
        [int]$Port
    )
    $connections = Get-NetTCPConnection -State Listen | Where-Object { $_.LocalPort -eq $Port }
    if ($connections) {
        foreach ($connection in $connections) {
            $process = Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue
            if ($process) {
                $process | Stop-Process -Force
                Write-Host "Stopped process $($process.Id) on port $Port."
            }
            else {
                Write-Host "No process found for connection on port $Port."
            }
        }
    }
    else {
        Write-Host "No process found on port $Port."
    }
}

# Stop the development server
$devPort = 8080
Stop-ProcessOnPort -Port $devPort

# Stop the production server
$prodPort = 8082
Stop-ProcessOnPort -Port $prodPort
