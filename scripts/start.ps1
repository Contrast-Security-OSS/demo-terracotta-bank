# Determine the directory where the script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Function to check if a port is in use
function Test-PortInUse {
    param ([int]$Port)
    $isInUse = Get-NetTCPConnection -State Listen | Where-Object { $_.LocalPort -eq $Port }
    return $isInUse -ne $null
}

# Check for Java and its version
$javaVersionOutput = java -version 2>&1
$javaVersionLine = $javaVersionOutput | Select-String 'version'
if ($javaVersionLine -ne $null) {
    $javaVersionString = $javaVersionLine -replace '.*version\s*"([0-9]+(\.[0-9]+)?).*"', '$1'
    $javaVersionParts = $javaVersionString.Split('.')
    $javaMajorVersion = if ($javaVersionParts[0] -eq '1') { $javaVersionParts[1] } else { $javaVersionParts[0] }
}
else {
    Write-Host "Java is not installed or version information is not recognized. Please install Java and try again."
    exit
}

Write-Host "Java version: $javaVersionString"
if ([int]$javaMajorVersion -lt 8 -or [int]$javaMajorVersion -gt 15) {
    Write-Host "Unsupported Java version: $javaVersionString. Please use Java between version 8 and 15."
    exit
}

# Check if the contrast_security.yaml file exists
$ConfigFile = Join-Path $ScriptDir "contrast_security.yaml"
if (-not (Test-Path $ConfigFile)) {
    Write-Host "Configuration file '$ConfigFile' not found. Please ensure it is present in the same directory as this script."
    exit
}

# Start the application in DEVELOPMENT mode (Assess)
$devPort = 8080
$devLog = Join-Path $ScriptDir "terracotta-dev.log"
if (Test-PortInUse -Port $devPort) {
    Write-Host "Development server port $devPort is already in use."
}
else {
    Start-Job -ScriptBlock {
        param($ScriptDir, $ConfigFile, $devPort, $devLog)
        java -Dcontrast.protect.enable=false `
             -Dcontrast.assess.enable=true `
             -Dcontrast.server.name=terracotta-dev `
             -Dcontrast.server.environment=DEVELOPMENT `
             -Dcontrast.config.path=$ConfigFile `
             -Dcontrast.agent.polling.app_activity_ms=1000 `
             -javaagent:"$ScriptDir\contrast-agent.jar" `
             -Dserver.port=$devPort `
             -jar "$ScriptDir\terracotta.war" *> $devLog
    } -ArgumentList $ScriptDir, $ConfigFile, $devPort, $devLog -Name "DevServerJob"
}

# Start the application in PRODUCTION mode (Protect)
$prodPort = 8082
$prodLog = Join-Path $ScriptDir "terracotta-prod.log"
if (Test-PortInUse -Port $prodPort) {
    Write-Host "Production server port $prodPort is already in use."
}
else {
    Start-Job -ScriptBlock {
        param($ScriptDir, $ConfigFile, $prodPort, $prodLog)
        java -Dcontrast.protect.enable=true `
             -Dcontrast.assess.enable=false `
             -Dcontrast.server.name=terracotta-prod `
             -Dcontrast.server.environment=PRODUCTION `
             -Dcontrast.config.path=$ConfigFile `
             -Dcontrast.agent.polling.app_activity_ms=1000 `
             -javaagent:"$ScriptDir\contrast-agent.jar" `
             -Dserver.port=$prodPort `
             -jar "$ScriptDir\terracotta.war" *> $prodLog
    } -ArgumentList $ScriptDir, $ConfigFile, $prodPort, $prodLog -Name "ProdServerJob"
}

# Check for job status or any immediate errors
Get-Job | Format-Table -Property Id, Name, State, HasMoreData
