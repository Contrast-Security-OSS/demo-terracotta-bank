#!/bin/bash

#This script takes hostname as a parameter. If no paramter is provided, then hostname will default to localhost
# Check if at least one parameter is provided

# Example to run the script - ./redeploy.sh http://example.com

if [ "$#" -eq 0 ]; then
    hostname='http://localhost'
    echo "You can also provide a custom hostname as a parameter"
    echo "Example to run the script - ./redeploy.sh example.com"
else
    hostname="$1"
    
fi

# Specify the URL
url="$hostname:8080/"
logout_url="$hostname:8080/logout"
login_url="$hostname:8080/login"



# Fisrt we we kill any running version of the application
echo "Stopping Terracota-Bank"
./stop.sh

# Wait 2 seconds
sleep 2

# Next we will checkout a new git branch for each time the user checks their code

timestamp=$(date +"%H-%M-%S")
new_branch="attempted-fix-$timestamp"
echo "Switching branch to: $new_branch"
git checkout -b "$new_branch"

# Let's start up the application under the new branch
# This should create updated session metadata and create a new vulnerability instance

# Before Starting the Application we will update the Session Metadata
java UpdateSessionMetadata

echo "Starting Terracota-Bank"
nohup ./gradlew bootRun -x test > logs/server.log 2>&1 &

# Wait 30 seconds for the app to start
echo "waiting 30 seconds for app to start"
sleep 30

# We will now execercise the login endpoint and monitor for the SQL injection vulnerability



echo "Checking if Terracota Bank is running."



# Make a GET request to the website and store the HTTP response code
# Function to check if the application is running
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

# Check if the application is running using a while loop
while [ $current_attempt -lt $max_attempts ]; do
    if check_application_running; then
        sleep 1
      
        curl "$logout_url"
        # Attempting login to ensure application is running properly!"
        sleep 2
        login_data="username=admin&password=admin&relay=&csrfToken=&login=LOGIN"
        curl -s -X POST -d "$login_data" "$login_url"
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


# If the loop completes without success
echo "Application failed to start within the specified time. Check 'logs/server.log' for more information."
exit 1


