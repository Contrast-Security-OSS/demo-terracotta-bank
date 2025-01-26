# Terracotta Bank: A deliberately insecure Java web application

This sample application is based on https://github.com/terracotta-bank/terracotta-bank

**Warning**: The computer running this application will be vulnerable to attacks, please take appropriate precautions.

## System Requirements

- Java 8 or higher (tested with Java 8)
- Gradle 8.12.1 or higher (included via wrapper)
- Spring Boot 2.7.18

# Running standalone

You can run Terracotta Bank locally on any machine with Java installed.

1. Place a `contrast_security.yaml` file into the application's root folder.
2. Place a `contrast.jar` into the application's root folder.
3. Run the application using `./gradlew bootRun`
4. Browse the application at http://localhost:8080/

# Running in Docker

You can run Terracotta Bank within a Docker container. 

1. Place a `contrast_security.yaml` file into the application's root folder.
2. Build the Terracotta Bank container image using `./1-Build-Docker-Image.sh`. The Contrast agent is added automatically during the Docker build process.
3. Run the container using:
   ```bash
   docker run -v $PWD/contrast_security.yaml:/etc/contrast/java/contrast_security.yaml -p 8080:8080 terracotta-bank:1.0
   ```
4. Browse the application at http://localhost:8080/

# Running in Azure (Azure Container Instance):

## Pre-Requisites

1. Place a `contrast_security.yaml` file into the application's root folder.
2. Install Terraform from here: https://www.terraform.io/downloads.html
3. Install PyYAML using `pip install PyYAML`
4. Install the Azure cli tools using `brew update && brew install azure-cli`
5. Log into Azure to make sure you cache your credentials using `az login`
6. Edit the [variables.tf](variables.tf) file (or add a terraform.tfvars) to add your initials, preferred Azure location, app name, server name and environment.
7. Run `terraform init` to download the required plugins.
8. Run `terraform plan` and check the output for errors.
9. Run `terraform apply` to build the infrastructure that you need in Azure, this will output the web address for the application.
10. Run `terraform destroy` when you would like to stop the app service and release the resources.

# Running automated tests

There are a number of Selenium tests which you can use to reveal vulnerabilities.

1. Place a `contrast_security.yaml` file into the application's root folder.
2. Place a `contrast.jar` into the application's root folder.
3. Ensure you have the Firefox browser installed.
4. Run the tests using `./gradlew cleanTest test`

Note: Tests have been updated to work with Selenium 4.3.0.

# Running automated tests in Docker
 
There are a number of Selenium tests which you can use to reveal vulnerabilities in a Docker container.
 
1. Place a `contrast_security.yaml` file into the application's root folder.
2. Build the Docker container using `docker build . -f Dockerfile.test -t terracotta-test`
3. Run the container using:
   ```bash
   docker run -v $PWD/contrast_security.yaml:/etc/contrast/java/contrast_security.yaml terracotta-test:latest
   ```

## Updating the Docker Image

You can re-build the docker image (used by Terraform) by running two scripts in order:

* 1-Build-Docker-Image.sh
* 2-Deploy-Docker-Image-To-Docker-Hub.sh

## Framework Updates

This application has been upgraded to use:
- Spring Boot 2.7.18 (from 1.5.1)
- Gradle 8.12.1
- Selenium 4.3.0
- Updated dependencies for enhanced security and performance
