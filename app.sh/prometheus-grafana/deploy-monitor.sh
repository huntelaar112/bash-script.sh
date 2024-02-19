#!/bin/bash

# smartocr - monitor@123

nginxnetwork="ocrnetwork"
nginxIP="172.172.0.200"
monitorNetwork="monitoring"
grafanaCon="grafana"

docker network create -o "com.docker.network.bridge.name"="monitoring" --driver=bridge --subnet=172.188.0.0/16 "${monitorNetwork}"
#[[ $? == 0 ]] && {
#    echo "Created network: '${dockerNetwork}'"
#}

chmod +x ./*.sh
./deploy-prometheus.sh "${monitorNetwork}"
sleep 1
./deploy-node-exporter.sh "${monitorNetwork}"
./deploy-cadvisor.sh "${monitorNetwork}" google/cadvisor:v0.28.0 #gcr.io/cadvisor/cadvisor
./deploy-telegraf.sh "${nginxIP}" "${monitorNetwork}"


docker network connect ${nginxnetwork} telegraf

echo "Connect grafana to network: "${monitorNetwork}""
docker network connect "${monitorNetwork}" "${grafanaCon}" &>/dev/null