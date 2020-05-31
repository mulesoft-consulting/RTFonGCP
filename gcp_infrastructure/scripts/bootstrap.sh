#!/bin/bash

# Installing curl
sudo yum install zip unzip -y

# Download and Extract install Scripts
curl -L https://anypoint.mulesoft.com/runtimefabric/api/download/scripts/latest --output rtf-install-scripts.zip
mkdir -p ./rtf-install-scripts && unzip rtf-install-scripts.zip -d ./rtf-install-scripts