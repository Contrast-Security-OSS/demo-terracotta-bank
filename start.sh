#!/bin/bash

# Start the application as a separate process in the background
nohup ./gradlew bootRun -x test > /dev/null 2>&1 &

echo "Terracotta Bank application started as a separate process."
