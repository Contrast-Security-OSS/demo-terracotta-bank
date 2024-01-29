#!/bin/bash

# Start the application as a separate process in the background
nohup ./gradlew bootRun -x test > /dev/null 2>&1 &

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
max_attempts=150
current_attempt=0
while [ $current_attempt -lt $max_attempts ]; do
    if check_application_running; then
    	sleep 1
	    echo "Application started successfully."
        exit 0
    else
        echo "Application not yet started. Waiting...trying again in 3 seconds"
        sleep 3
        ((current_attempt++))
    fi
done

echo "Application failed to start within the specified time. Check the logs for more information."
exit 1