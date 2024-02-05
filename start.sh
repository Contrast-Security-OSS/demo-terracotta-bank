#!/bin/bash

# Check if any Terracotta Bank app is currently running
if pgrep -f java > /dev/null; then
    echo "[!ERROR] It seems like a process of Terracotta Bank is already running. Please run './stop.sh' before trying to start the application."
    exit 1
fi

# Before Starting the Application we will update the Session Metadata
java UpdateSessionMetadata

# Ensure log folder exists before starting application
mkdir -p logs

# Start the application as a separate process in the background
nohup ./gradlew bootRun -x test > logs/server.log 2>&1 &

echo " Starting Terracotta Bank application started as a separate process. This may take up to 30 seconds!"
sleep 30


#This script takes hostname as a parameter. If no paramter is provided, then hostname will default to localhost
# Check if at least one parameter is provided

# Example to run the script - ./start.sh http://example.com

if [ "$#" -eq 0 ]; then
    hostname='http://localhost'
    echo "You can also provide a custom hostname as a parameter"
else
	hostname="$1"
	
fi

# Specify the URL
url="$hostname:8080/"
check_application_running() {
    http_status=$(curl --write-out "%{http_code}" --silent --output /dev/null "$url")
    echo "http status + $http_status"

    if [ "$http_status" -eq 200 ]; then
	    echo "Website is running (HTTP 200 OK)"
	    return 0
	else
		echo "the Terracota Bank Application has not been started correctly. (HTTP $http_status)"
		return 1
	fi
}

# Maximum number of attempts to check if the application is running
max_attempts=50
current_attempt=0
while [ $current_attempt -lt $max_attempts ]; do
    if check_application_running; then
    	sleep 1
	    echo "Application started successfully."
        exit 0
    else

        # Checking for errors
        log_file="logs/server.log"

        # Use tail to grab the last 5 lines of the file
        last_five_lines=$(tail -n 5 "$log_file")

        # Check if 'Build Failed' exists in the last 5 lines
        if echo "$last_five_lines" | grep -q "BUILD FAILED"; then
            echo "Build Failed with errors. Please check 'logs/server.log' for more information!"
            exit 1
        else
        

            echo "Application not yet started. Waiting...trying again in 3 seconds"
            sleep 3
            ((current_attempt++))
        fi
    fi
done

echo "Application failed to start within the specified time. Check the 'logs/server.log' for more information."
exit 1
