@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Function to check if a port is in use
:is_port_in_use
netstat -ano | findstr :%1 | findstr LISTENING > nul
if %ERRORLEVEL% == 0 (
    echo Port %1 is already in use.
    exit /b 1
) else (
    exit /b 0
)

:: Function to wait for server readiness
:wait_for_server
SET PORT=%1
:server_poll_loop
powershell -Command "(New-Object Net.Sockets.TcpClient).Connect('localhost', %PORT%)" > nul 2>&1
IF NOT %ERRORLEVEL% == 0 (
    echo Waiting for server on port %PORT%...
    TIMEOUT /T 2 /NOBREAK > nul
    GOTO server_poll_loop
)
echo Server on port %PORT% is ready!
exit /b 0

:: Check if the contrast_security.yaml file exists
IF NOT EXIST contrast_security.yaml (
    echo Configuration file 'contrast_security.yaml' not found.
    exit /b 1
)

:: Start the application in DEVELOPMENT mode (Assess)
call :is_port_in_use 8080
IF %ERRORLEVEL% == 1 exit /b 1

start /b cmd /c java -Dcontrast.protect.enable=false -Dcontrast.assess.enable=true ^
    -Dcontrast.server.environment=DEVELOPMENT -Dserver.port=8080 ^
    -Dcontrast.config.path=contrast_security.yaml ^
    -javaagent:contrast-agent.jar -jar terracotta.war > terracotta-dev.log

call :wait_for_server 8080

:: Start the application in PRODUCTION mode (Protect)
call :is_port_in_use 8082
IF %ERRORLEVEL% == 1 exit /b 1

start /b cmd /c java -Dcontrast.protect.enable=true -Dcontrast.assess.enable=false ^
    -Dcontrast.server.environment=PRODUCTION -Dserver.port=8082 ^
    -Dcontrast.config.path=contrast_security.yaml ^
    -javaagent:contrast-agent.jar -jar terracotta.war > terracotta-prod.log

call :wait_for_server 8082

echo Both servers started.
exit /b 0
