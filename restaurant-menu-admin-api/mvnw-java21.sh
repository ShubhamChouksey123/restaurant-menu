#!/bin/bash

# This script runs Maven commands with Java 21
# Usage: ./mvnw-java21.sh clean install
#        ./mvnw-java21.sh spring-boot:run

export JAVA_HOME=/Users/schouksey/Library/Java/JavaVirtualMachines/corretto-21.0.4/Contents/Home

echo "Using Java 21: $JAVA_HOME"
java -version

mvn "$@"
