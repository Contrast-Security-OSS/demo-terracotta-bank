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

# Stop the development server
DEV_PORT=8080
stop_process_on_port $DEV_PORT

# Stop the production server
PROD_PORT=8082
stop_process_on_port $PROD_PORT
