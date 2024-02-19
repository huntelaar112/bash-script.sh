#!/bin/bash

set -e
source ${1}

docker run \
    --rm \
    -e SONAR_HOST_URL="https://${SONARQUBE_URL}" \
    -e SONAR_SCANNER_OPTS="-Dsonar.projectKey=${YOUR_PROJECT_KEY} -Dsonar.exclusions=**/*.java" \
    -e SONAR_TOKEN="${SONAR_TOKEN}" \
    -v "${YOUR_REPO}:/usr/src" \
    sonarsource/sonar-scanner-cli
