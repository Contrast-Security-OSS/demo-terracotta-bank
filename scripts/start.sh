#!/bin/bash

# Function to check if a port is in use
is_port_in_use() {
    netstat -an | grep "$1" | grep LISTEN >/dev/null
    return $?
}

# Function to check if the application is ready
wait_for_server() {
    PORT=$1
    ENVIRONMENT=$2
    MAX_ATTEMPTS=60
    ATTEMPTS=0
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

# Check for Java and its version
JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
if [[ -z "$JAVA_VERSION" ]]; then
    echo "Java is not installed. Please install Java and try again."
    exit 1
else
    JAVA_MAJOR_VERSION=$(echo "$JAVA_VERSION" | cut -d'.' -f1)
    if [[ "$JAVA_MAJOR_VERSION" == "1" ]]; then
        JAVA_MAJOR_VERSION=$(echo "$JAVA_VERSION" | cut -d'.' -f1-2 | cut -d'.' -f2)
    fi
    echo "Java version: $JAVA_VERSION"
    if [[ "$JAVA_MAJOR_VERSION" -lt 8 || "$JAVA_MAJOR_VERSION" -gt 15 ]]; then
        echo "Unsupported Java version: $JAVA_VERSION. Please use Java between version 8 and 15."
        exit 1
    fi
fi

# Check if the contrast_security.yaml file exists
CONFIG_FILE="contrast_security.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file '$CONFIG_FILE' not found. Please ensure it is present in the same directory as this script."
    exit 1
fi

# Start the application in DEVELOPMENT mode (Assess)
DEV_PORT=8080
DEV_LOG="terracotta-dev.log"
if is_port_in_use $DEV_PORT; then
    echo "Development server port $DEV_PORT is already in use."
    exit 1
else
    nohup java -Dcontrast.protect.enable=false \
        -Dcontrast.assess.enable=true \
        -Dcontrast.server.name=terracotta-dev \
        -Dcontrast.server.environment=DEVELOPMENT \
        -Dcontrast.config.path=$CONFIG_FILE \
        -Dcontrast.agent.polling.app_activity_ms=1000 \
        -javaagent:contrast-agent.jar \
        -Dserver.port=$DEV_PORT \
        -jar terracotta.war >$DEV_LOG 2>&1 &
    wait_for_server $DEV_PORT "DEVELOPMENT"
fi

# Start the application in PRODUCTION mode (Protect)
PROD_PORT=8082
PROD_LOG="terracotta-prod.log"
if is_port_in_use $PROD_PORT; then
    echo "Production server port $PROD_PORT is already in use."
    exit 1
else
    nohup java -Dcontrast.protect.enable=true \
        -Dcontrast.assess.enable=false \
        -Dcontrast.server.name=terracotta-prod \
        -Dcontrast.server.environment=PRODUCTION \
        -Dcontrast.config.path=$CONFIG_FILE \
        -Dcontrast.agent.polling.app_activity_ms=1000 \
        -javaagent:contrast-agent.jar \
        -Dserver.port=$PROD_PORT \
        -jar terracotta.war >$PROD_LOG 2>&1 &
    wait_for_server $PROD_PORT "PRODUCTION"
fi
