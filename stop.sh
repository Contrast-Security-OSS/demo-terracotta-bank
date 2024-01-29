#!/bin/bash

# Check if there are active Java processes
if pgrep -f "java" > /dev/null; then
    # Kill all Java applications
    pkill -f "java"
    echo "Terracotta Bank Stopped"
else
    echo "Application was not running, so no action taken"
fi
