#!/bin/bash

# Specify the process ID
process_pid=$(pgrep -f "gradlew")

# Stop the process using kill
kill "$process_pid"

echo "Java application stopped."
