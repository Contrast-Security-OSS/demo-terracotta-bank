# Function to check if a port is in use
function Test-PortInUse {
    param ([int]$Port)
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

# Function to wait for server readiness with a timeout
function Wait-ForServer {
    param ([int]$Port, [string]$Environment)
    $MAX_ATTEMPTS = 60
    $ATTEMPTS = 0
    Write-Host "Waiting for $Environment server on port $Port to be ready..."
    do {
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $tcpClient.Connect('localhost', $Port)
            $tcpClient.Close()
            Write-Host "$Environment server on port $Port is ready!"
            break
        } catch {
            if ($ATTEMPTS -ge $MAX_ATTEMPTS) {
                Write-Host "Timeout reached. $Environment server on port $Port is not responding."
                exit
            }
            Start-Sleep -Seconds 2
            $ATTEMPTS++
        }
    } while ($true)
}

# Check for Java and its version
try {
    $javaVersionOutput = (java -version 2>&1)
    $javaVersion = $javaVersionOutput[0].Split('"')[1]
    $javaMajorVersion = $javaVersion -replace '1\.', '' -replace '\..*', ''
    Write-Host "Java version: $javaVersion"
    if ($javaMajorVersion -lt 8 -or $javaMajorVersion -gt 15) {
        Write-Host "Unsupported Java version: $javaVersion. Please use Java between version 8 and 15."
        exit
    }
} catch {
    Write-Host "Java is not installed. Please install Java and try again."
    exit
}

# Check if the contrast_security.yaml file exists
$configFile = "contrast_security.yaml"
if (-not (Test-Path $configFile)) {
    Write-Host "Configuration file '$configFile' not found."
    exit
}

# Start the application in DEVELOPMENT mode (Assess)
$devPort = 8080
if (Test-PortInUse -Port $devPort) {
    Write-Host "Development server port $devPort is already in use."
    exit
} else {
    Start-Process -FilePath "java" -ArgumentList "-Dcontrast.protect.enable=false", "-Dcontrast.assess.enable=true", "-Dcontrast.server.name=terracotta-dev", "-Dcontrast.server.environment=DEVELOPMENT", "-Dcontrast.config.path=$configFile", "-Dcontrast.agent.polling.app_activity_ms=1000", "-javaagent:contrast-agent.jar", "-Dserver.port=$devPort", "-jar", "terracotta.war" -RedirectStandardOutput "terracotta-dev.log" -NoNewWindow -PassThru
    Wait-ForServer -Port $devPort -Environment "DEVELOPMENT"
}

# Start the application in PRODUCTION mode (Protect)
$prodPort = 8082
if (Test-PortInUse -Port $prodPort) {
    Write-Host "Production server port $prodPort is already in use."
    exit
} else {
    Start-Process -FilePath "java" -ArgumentList "-Dcontrast.protect.enable=true", "-Dcontrast.assess.enable=false", "-Dcontrast.server.name=terracotta-prod", "-Dcontrast.server.environment=PRODUCTION", "-Dcontrast.config.path=$configFile", "-Dcontrast.agent.polling.app_activity_ms=1000", "-javaagent:contrast-agent.jar", "-Dserver.port=$prodPort", "-jar", "terracotta.war" -RedirectStandardOutput "terracotta-prod.log" -NoNewWindow -PassThru
    Wait-ForServer -Port $prodPort -Environment "PRODUCTION"
}

Write-Host "Both servers started."
