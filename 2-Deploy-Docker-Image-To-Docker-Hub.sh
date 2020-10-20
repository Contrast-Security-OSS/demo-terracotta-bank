#!/bin/bash

echo "Please log in using your Docker Hub credentials to update the container image"
docker login
docker tag terracotta-bank:1.0 contrastsecuritydemo/terracotta-bank:1.0
docker push contrastsecuritydemo/terracotta-bank:1.0
