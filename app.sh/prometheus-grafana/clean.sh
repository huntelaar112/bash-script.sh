#!/bin/bash

echo "__Remove container and docker network:"

docker rm -f node-exporter
docker rm -f prometheus
docker rm -f cadvisor
docker rm -f telegraf

docker network disconnect monitoring grafana
docker network rm monitoring
