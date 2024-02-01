@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Function to stop a process listening on a port
:: Syntax: call :stop_process_on_port [port_number]
:stop_process_on_port
FOR /F "tokens=5" %%i IN ('netstat -ano ^| findstr :%1 ^| findstr LISTENING') DO (
    SET /A "PID=%%i"
    taskkill /PID !PID! /F > nul 2>&1
    IF !ERRORLEVEL! == 0 (
        echo Stopped process on port %1.
    ) ELSE (
        echo No process found on port %1.
    )
    exit /b 0
)

:: Stop the development server
call :stop_process_on_port 8080

:: Stop the production server
call :stop_process_on_port 8082

echo Both servers stopped.
exit /b 0
