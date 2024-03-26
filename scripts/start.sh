#!/bin/bash

# Function to check if a port is in use
is_port_in_use() {
    local PORT=$1
    netstat -an | grep "$PORT" | grep LISTEN >/dev/null
    return $?
}

# Function to check if the application is ready
wait_for_server() {
    local PORT=$1
    local ENVIRONMENT=$2
    local MAX_ATTEMPTS=60
    local ATTEMPTS=0
    echo "Waiting for $ENVIRONMENT server on port $PORT to be ready..."
    while ! curl --output /dev/null --silent --head --fail http://localhost:"$PORT"; do
        if [ $ATTEMPTS -ge $MAX_ATTEMPTS ]; then
            echo "Timeout reached. $ENVIRONMENT server on port $PORT is not responding."
            exit 1
        fi
        printf '.'
        sleep 2
        ATTEMPTS=$((ATTEMPTS + 1))
    done
    echo "$ENVIRONMENT server on port $PORT is ready!"
}

# Check Java version
check_java_version() {
    local MIN_VERSION=8
    local MAX_VERSION=15
    local JAVA_VERSION
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    if [[ -z "$JAVA_VERSION" ]]; then
        echo "Java is not installed. Please install Java and try again."
        exit 1
    else
        local JAVA_MAJOR_VERSION
        JAVA_MAJOR_VERSION=$(echo "$JAVA_VERSION" | cut -d'.' -f1)
        if [[ "$JAVA_MAJOR_VERSION" == "1" ]]; then
            JAVA_MAJOR_VERSION=$(echo "$JAVA_VERSION" | cut -d'.' -f1-2 | cut -d'.' -f2)
        fi
        echo "Java version: $JAVA_VERSION"
        if ((JAVA_MAJOR_VERSION < MIN_VERSION || JAVA_MAJOR_VERSION > MAX_VERSION)); then
            echo "Unsupported Java version: $JAVA_VERSION. Please use Java between version $MIN_VERSION and $MAX_VERSION."
            exit 1
        fi
    fi
}

# Check if the contrast_security.yaml file exists
check_config_file() {
    local CONFIG_FILE="$SCRIPT_DIR/contrast_security.yaml"
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Configuration file '$CONFIG_FILE' not found. Please ensure it is present in the same directory as this script."
        exit 1
    fi
}

# Function to start the application
start_application() {
    local PORT=$1
    local ENVIRONMENT=$2
    local LOG_FILE="$SCRIPT_DIR/terracotta-$ENVIRONMENT.log"

    if is_port_in_use "$PORT"; then
        echo "$ENVIRONMENT server port $PORT is already in use."
        exit 1
    fi

    nohup java \
        -Dcontrast.protect.enable=$PROTECT_ENABLE \
        -Dcontrast.assess.enable=$ASSESS_ENABLE \
        -Dcontrast.server.name=terracotta-"$ENVIRONMENT" \
        -Dcontrast.server.environment="$ENVIRONMENT" \
        -Dcontrast.config.path="$CONFIG_FILE" \
        -Dcontrast.agent.polling.app_activity_ms=1000 \
        -javaagent:"$SCRIPT_DIR/contrast-agent.jar" \
        -Dserver.port="$PORT" \
        -jar "$SCRIPT_DIR/terracotta.war" >"$LOG_FILE" 2>&1 &

    wait_for_server "$PORT" "$ENVIRONMENT"
}

# Main script

# Determine the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Configuration options
PROTECT_ENABLE=false
ASSESS_ENABLE=false

# Check Java version
check_java_version

# Check configuration file
check_config_file

# Start the application based on command-line arguments
case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
    "assess")
        ASSESS_ENABLE=true
        start_application 8080 "DEVELOPMENT"
        ;;
    "protect")
        PROTECT_ENABLE=true
        start_application 8082 "PRODUCTION"
        ;;
    "all")
        ASSESS_ENABLE=true
        PROTECT_ENABLE=true
        start_application 8080 "DEVELOPMENT"
        start_application 8082 "PRODUCTION"
        ;;
    *)
        echo "Usage: $0 {assess|protect|all}"
        exit 1
esac
