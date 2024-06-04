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

# Stop the application based on command-line arguments
if [[ -z "$1" ]]; then
    COMMAND="all"
    if [ -z "$2" ]; then
        ASSESS_PORT=8080
        PROTECT_PORT=8082
    else
        ASSESS_PORT=$2
        PROTECT_PORT=$3
    fi
else
    COMMAND="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
    if [[ $COMMAND == "assess" ]]; then
        if [[ -z "$2" ]]; then
            ASSESS_PORT=8080
        else
            ASSESS_PORT=$2
        fi
    elif [[ $COMMAND == "protect" ]]; then
        if [[ -z "$2" ]]; then
            PROTECT_PORT=8082
        else
            PROTECT_PORT=$2
        fi
    elif [[ $COMMAND == "all" ]]; then
        if [[ -z "$2" ]]; then
            ASSESS_PORT=8080
            PROTECT_PORT=8082
        else
            ASSESS_PORT=$2
            PROTECT_PORT=$3
        fi
    fi
fi
echo "Command: $COMMAND"
echo "Assess Port: $ASSESS_PORT"
echo "Protect Port: $PROTECT_PORT"

# If the command is not provided
case "$COMMAND" in
"assess")
    stop_process_on_port "$ASSESS_PORT" "DEVELOPMENT"
    ;;
"protect")
    stop_process_on_port "$PROTECT_PORT" "PRODUCTION"
    ;;
"all")
    stop_process_on_port "$ASSESS_PORT" "DEVELOPMENT"
    stop_process_on_port "$PROTECT_PORT" "PRODUCTION"
    ;;
*)
    echo "Usage: $0 {assess|protect|all} [ASSESS_PORT] [PROTECT_PORT]"
    exit 1
    ;;
esac
