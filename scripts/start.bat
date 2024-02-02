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

:: Function to wait for server readiness with a timeout
:wait_for_server
SET PORT=%1
SET ENVIRONMENT=%2
SET MAX_ATTEMPTS=60
SET /A ATTEMPTS=0
echo Waiting for %ENVIRONMENT% server on port %PORT% to be ready...
:server_poll_loop
powershell -Command "(New-Object Net.Sockets.TcpClient).Connect('localhost', %PORT%)" > nul 2>&1
IF %ERRORLEVEL% == 0 (
    echo %ENVIRONMENT% server on port %PORT% is ready!
    exit /b 0
)
IF !ATTEMPTS LSS %MAX_ATTEMPTS% (
    SET /A ATTEMPTS+=1
    TIMEOUT /T 2 /NOBREAK > nul
    GOTO server_poll_loop
) ELSE (
    echo Timeout reached. %ENVIRONMENT% server on port %PORT% is not responding.
    exit /b 1
)

:: Check for Java and its version
FOR /F "tokens=*" %%i IN ('java -version 2^>^&1') DO (
    SET JAVA_VERSION=%%i
    GOTO :check_java_version
)
:check_java_version
ECHO %JAVA_VERSION% | FIND "version" > nul
IF %ERRORLEVEL% NEQ 0 (
    echo Java is not installed. Please install Java and try again.
    exit /b 1
)
FOR /F "tokens=3" %%j IN ("%JAVA_VERSION%") DO (
    SET JAVA_VERSION_FULL=%%j
    SET JAVA_VERSION_FULL=!JAVA_VERSION_FULL:"=!
)
FOR /F "tokens=1-2 delims=." %%k IN ("!JAVA_VERSION_FULL!") DO (
    SET JAVA_MAJOR_VERSION=%%k
    SET JAVA_MINOR_VERSION=%%l
)
IF "!JAVA_MAJOR_VERSION!" == "1" (
    SET JAVA_MAJOR_VERSION=!JAVA_MINOR_VERSION!
)
ECHO Java version: !JAVA_MAJOR_VERSION!
IF !JAVA_MAJOR_VERSION! LSS 8 OR !JAVA_MAJOR_VERSION! GTR 15 (
    echo Unsupported Java version: !JAVA_VERSION_FULL!. Please use Java between version 8 and 15.
    exit /b 1
)

:: Check if the contrast_security.yaml file exists
IF NOT EXIST contrast_security.yaml (
    echo Configuration file 'contrast_security.yaml' not found.
    exit /b 1
)

:: Start the application in DEVELOPMENT mode (Assess)
call :is_port_in_use 8080
IF %ERRORLEVEL% == 1 exit /b 1

start /b cmd /c java -Dcontrast.protect.enable=false ^
    -Dcontrast.assess.enable=true ^
    -Dcontrast.server.name=terracotta-dev ^
    -Dcontrast.server.environment=DEVELOPMENT ^
    -Dcontrast.config.path=contrast_security.yaml ^
    -Dcontrast.agent.polling.app_activity_ms=1000 ^
    -javaagent:contrast-agent.jar ^
    -Dserver.port=8080 ^
    -jar terracotta.war > terracotta-dev.log

call :wait_for_server 8080 "DEVELOPMENT"

:: Start the application in PRODUCTION mode (Protect)
call :is_port_in_use 8082
IF %ERRORLEVEL% == 1 exit /b 1

start /b cmd /c java -Dcontrast.protect.enable=true ^
    -Dcontrast.assess.enable=false ^
    -Dcontrast.server.name=terracotta-prod ^
    -Dcontrast.server.environment=PRODUCTION ^
    -Dcontrast.config.path=contrast_security.yaml ^
    -Dcontrast.agent.polling.app_activity_ms=1000 ^
    -javaagent:contrast-agent.jar ^
    -Dserver.port=8082 ^
    -jar terracotta.war > terracotta-prod.log

call :wait_for_server 8082 "PRODUCTION"

echo Both servers started.
exit /b 0
