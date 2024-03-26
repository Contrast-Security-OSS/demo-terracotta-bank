# Application Startup Script

These scripts are designed to start and stop an application in different environments (Development or Production) or both simultaneously. They provide options to manage the application instances effectively.

## Start Script (start.sh)

This script starts the application in various environments based on the provided command-line arguments.

### Usage

```bash
./start.sh <environment> [port]
```

Replace `<environment>` with one of the following options:
* `assess`: Start the application in Development mode (Assess) only.
* `protect`: Start the application in Production mode (Protect) only.
* `all`: Start both Development and Production environments (Assess and Protect) simultaneously.

The optional [port] argument allows specifying a custom port for the application. If not provided, default ports will be used.

### Prerequisites
Before running the script, ensure the following prerequisites are met:

**Java**: Java Development Kit (JDK) version 8 to 15 is required. Install Java if not already available on your system.

**contrast_security.yaml**: Ensure the contrast_security.yaml configuration file is present in the same directory as the script. This file contains the configuration settings for the Contrast Security agent.

**contrast-agent.jar**: Make sure the Contrast Security agent JAR file (contrast-agent.jar) is available in the script directory.

### Logging
Log files (terracotta-dev.log and terracotta-prod.log) are generated in the script directory to capture application startup logs and error messages.

## Stop Script (stop.sh)
This script stops the running instances of the application based on the provided command-line arguments.

### Usage
```bash
./stop.sh <environment>
```

Replace `<environment>` with one of the following options:
* `assess`: Stop the application instance running in Development mode (Assess).
* `protect`: Stop the application instance running in Production mode (Protect).
* `all`: Stop all running instances of the application.

### Functionality
The `stop.sh` script identifies the running processes based on the specified environment and terminates them gracefully.

## Contributing
Contributions to this script are welcome! If you find any issues or have suggestions for improvements, please submit a pull request or open an issue [on GitHub](https://github.com/Contrast-Security-OSS/demo-terracotta-bank).