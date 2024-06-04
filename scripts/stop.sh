#!/bin/bash

# Text Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
WHITE=$(tput setaf 7)
GREY=$(tput setaf 8)
RESET=$(tput sgr0)

print_success() {
    echo -e "${GREEN}SUCCESS: $1${RESET}"
}

print_error() {
    echo -e "${RED}ERROR: $1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${RESET}"
}

print_info() {
    echo -e "${WHITE}INFO: $1${RESET}"
}

print_debug() {
    echo -e "${GREY}DEBUG: $1${RESET}"
}

# Function to stop processes listening on a port
stop_process_on_port() {
    PIDS=$(lsof -t -i:"$1")

    if [ -z "$PIDS" ]; then
        print_error "No process found on port $1."
        return
    fi

    for PID in $PIDS; do
        if kill "$PID" >/dev/null 2>&1; then
            print_success "Stopped process $PID on port $1."
        else
            print_error "Failed to stop process $PID on port $1."
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
    print_error "Usage: $0 {assess|protect|all} [ASSESS_PORT] [PROTECT_PORT]"
    exit 1
    ;;
esac
