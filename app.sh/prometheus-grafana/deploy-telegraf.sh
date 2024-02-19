#!/bin/bash

set -e
done=no
exitval=0

namescrpit=${0:2}
source $(which logshell)

function help() {
  echo "Usage: ${namescrpit} <nginxIp> [dockerNetwork] [image:tag]
  default image: \"telegraf:latest\"
  Note: This script need sudo permission to execute."
  exit ${exitval}
}

conname="telegraf"

nginxIp=$1
dockerNetwork=$2
image=$3

[[ -z ${1} || ${1} = "-h" ]] && {
  help
}

[[ -z ${image} ]] && {
  log-info "Default: Use image \"mannk98/telegraf:latest\""
  image="mannk98/telegraf:latest"
}

[[ -z ${dockerNetwork} ]] && {
  dockerNetwork="bridge"
  log-info "Default: Use bridge network."
}

telegraf_conf="
[[inputs.nginx]]
  urls = [\"http://${nginxIp}/status/nginx_status\"]
  response_timeout = \"5s\"

[[inputs.tail]]
  name_override = \"nginxlog\"
  files = [\"/tmp/nginx2commonlog/telegraf-nginx-access.log\"]
  from_beginning = true
  pipe = true
  data_format = \"grok\"
  grok_patterns = [\"%{COMBINED_LOG_FORMAT}\"]
  grok_timezone = \"Asia/Ho_Chi_Minh\"

[[inputs.cpu]]
  percpu = false
  totalcpu = true
  collect_cpu_time = true
  report_active = true
[[inputs.disk]]
[[inputs.diskio]]
[[inputs.net]]
[[inputs.mem]]
[[inputs.system]]

[[outputs.prometheus_client]]
    listen = \"0.0.0.0:8094\"
"

echo "${telegraf_conf}" >telegraf.conf

# last 90 days log nginx
docker run -idt --name ${conname} --hostname ${conname} --restart always -e DAYS="90" -e PATHLOG="/tmp/nginx2commonlog/telegraf-nginx-access.log" \
    --network ${dockerNetwork} --ip "172.188.0.4" \
    -v $(pwd)/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
    -v /mnt/containerdata/nginxgen/var_log_nginx:/mnt/containerdata/nginxgen/var_log_nginx:ro \
    -e TZ=Asia/Ho_Chi_Minh "${image}"

log-step "Done. telegraf deployed."
done=yes
# --security-opt seccomp=unconfined\