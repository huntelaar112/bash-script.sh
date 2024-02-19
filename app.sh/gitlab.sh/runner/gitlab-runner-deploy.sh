#!/bin/bash

docker volume create gitlab-runner-config

docker run -idt --name gitlab-runner --hostname gitlab-runner --restart always \
  -e TZ=Asia/Ho_Chi_Minh \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v gitlab-runner-config:/etc/gitlab-runner \
  gitlab/gitlab-runner:latest
