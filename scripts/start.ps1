# Function to check if a port is in use
function Test-PortInUse {
    param (
        [int]$Port
    )
    $endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, $Port)
    $socket = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
    try {
        $socket.Bind($endpoint)
        $false
    } catch {
        $true
    } finally {
        $socket.Close()
    }
}

# Function to wait for server readiness
function Wait-ForServer {
    param (
        [int]$Port
    )
    do {
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $tcpClient.Connect('localhost', $Port)
            $tcpClient.Close()
            Write-Host "Server on port $Port is ready!"
            break
        } catch {
            Write-Host "Waiting for server on port $Port..."
            Start-Sleep -Seconds 2
        }
    } while ($true)
}

# Check if contrast_security.yaml exists
$configFile = "contrast_security.yaml"
if (-not (Test-Path $configFile)) {
    Write-Host "Configuration file '$configFile' not found."
    exit
}

# Start in DEVELOPMENT mode (Assess)
$devPort = 8080
if (Test-PortInUse -Port $devPort) {
    Write-Host "Port $devPort is already in use."
} else {
    Start-Process -FilePath "java" -ArgumentList "-Dcontrast.protect.enable=false", "-Dcontrast.assess.enable=true", "-Dcontrast.server.environment=DEVELOPMENT", "-Dserver.port=$devPort", "-Dcontrast.config.path=$configFile", "-javaagent:contrast-agent.jar", "-jar", "terracotta.war" -RedirectStandardOutput "terracotta-dev.log" -NoNewWindow -PassThru
    Wait-ForServer -Port $devPort
}

# Start in PRODUCTION mode (Protect)
$prodPort = 8082
if (Test-PortInUse -Port $prodPort) {
    Write-Host "Port $prodPort is already in use."
} else {
    Start-Process -FilePath "java" -ArgumentList "-Dcontrast.protect.enable=true", "-Dcontrast.assess.enable=false", "-Dcontrast.server.environment=PRODUCTION", "-Dserver.port=$prodPort", "-Dcontrast.config.path=$configFile", "-javaagent:contrast-agent.jar", "-jar", "terracotta.war" -RedirectStandardOutput "terracotta-prod.log" -NoNewWindow -PassThru
    Wait-ForServer -Port $prodPort
}
