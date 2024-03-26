#!/bin/bash

# Function to stop processes listening on a port
stop_process_on_port() {
    PIDS=$(lsof -t -i:"$1")

    if [ -z "$PIDS" ]; then
        echo "No process found on port $1."
        return
    fi

    for PID in $PIDS; do
        if kill "$PID" > /dev/null 2>&1; then
            echo "Stopped process $PID on port $1."
        else
            echo "Failed to stop process $PID on port $1."
        fi
    done
}

# Check if an argument is provided
if [ -n "$1" ]; then
    # Stop the specified instance based on the argument
    case "$1" in
        "assess")
            DEV_PORT=8080
            stop_process_on_port $DEV_PORT
            ;;
        "protect")
            PROD_PORT=8082
            stop_process_on_port $PROD_PORT
            ;;
        "all")
            DEV_PORT=8080
            PROD_PORT=8082
            stop_process_on_port $DEV_PORT
            stop_process_on_port $PROD_PORT
            ;;
        *)
            echo "Invalid argument. Usage: ./stop.sh {assess|protect|all}"
            exit 1
    esac
else
    # Default behavior: Stop all instances if no argument is provided
    DEV_PORT=8080
    PROD_PORT=8082
    stop_process_on_port $DEV_PORT
    stop_process_on_port $PROD_PORT
fi
