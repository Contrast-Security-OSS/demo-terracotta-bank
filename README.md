# Terracotta Bank: A deliberately insecure Java web application

This sample application is based on https://github.com/terracotta-bank/terracotta-bank

**Warning**: The computer running this application will be vulnerable to attacks, please take appropriate precautions.

# Running standalone

You can run Terracotta Bank locally on any machine with Java 1.8 RE installed.

1. Place a `contrast_security.yaml` file into the application's root folder.
1. Place a `contrast.jar` into the application's root folder.
1. Run the application using ./gradlew bootRun
1. Browse the application at http://localhost:8080/

# Running in Docker

You can run Terracotta Bank within a Docker container. 

1. Place a `contrast_security.yaml` file into the application's root folder.
1. Build the Terracotta Bank container image using `./1-Build-Docker-Image.sh`. The Contrast agent is added automatically during the Docker build process.
1. Run the container using `docker run -v $PWD/contrast_security.yaml:/etc/contrast/java/contrast_security.yaml -p 8080:8080 terracotta-bank:1.0`
1. Browse the application at http://localhost:8080/

# Running in Azure (Azure Container Instance):

## Pre-Requisites

1. Place a `contrast_security.yaml` file into the application's root folder.
1. Install Terraform from here: https://www.terraform.io/downloads.html.
1. Install PyYAML using `pip install PyYAML`.
1. Install the Azure cli tools using `brew update && brew install azure-cli`.
1. Log into Azure to make sure you cache your credentials using `az login`.
1. Edit the [variables.tf](variables.tf) file (or add a terraform.tfvars) to add your initials, preferred Azure location, app name, server name and environment.
1. Run `terraform init` to download the required plugins.
1. Run `terraform plan` and check the output for errors.
1. Run `terraform apply` to build the infrastructure that you need in Azure, this will output the web address for the application.
1. Run `terraform destroy` when you would like to stop the app service and release the resources.

# Running automated tests

There are a number of Seleneum tests which you can use to reveal vulnerabilities.

1. Place a `contrast_security.yaml` file into the application's root folder.
1. Place a `contrast.jar` into the application's root folder.
1. Ensure you have the Firefox browser installed.
1. Run the application using `./gradlew cleanTest test`

# Running automated tests in Docker
 
There are a number of Seleneum tests which you can use to reveal vulnerabilities in a Docker container.
 
 1. Place a `contrast_security.yaml` file into the application's root folder.
 1. Build the Docker container using `docker build . -f Dockerfile.test -t terracotta-test`
 1. Run the container using `docker run -v $PWD/contrast_security.yaml:/etc/contrast/java/contrast_security.yaml terracotta-test:latest`

## Updating the Docker Image

You can re-build the docker image (used by Terraform) by running two scripts in order:

* 1-Build-Docker-Image.sh
* 2-Deploy-Docker-Image-To-Docker-Hub.sh
