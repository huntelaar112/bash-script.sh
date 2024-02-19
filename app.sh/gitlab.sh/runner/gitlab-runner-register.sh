#!/bin/bash

serverUrl=${1}
runnerToken=${2}

docker run --rm \
  -v gitlab-runner-config:/etc/gitlab-runner \
  gitlab/gitlab-runner register \
  --non-interactive \
  --executor "docker" \
  --docker-image debian:latest \
  --url "${serverUrl}" \
  --token "${runnerToken}" \
  --description "mannk-runner"
