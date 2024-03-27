#!/bin/bash

set -e
exitval=0

namescrpit=${0:2}
source $(which logshell)

function help() {
  echo "Usage: ${namescrpit} zbagent.env
  default image: \"mannk98/zabbix-agent2:6.4ubuntu\"
  Note: This script need sudo permission to execute."
  exit ${exitval}
}

[[ -z ${1} || ${1} = "-h" ]] && {
  help
}

source ${1}

[[ ! -z "${conip}" ]] && {
  containerIP="--ip ${conip}"
} || containerIP=""

[[ -z ${image} ]] && {
  log-info "Default: Use image \"mannk98/zabbix-agent2:6.4ubuntu\""
  image="mannk98/zabbix-agent2:6.4ubuntu"
}

[[ -z ${dockerNetwork} ]] && {
  dockerNetwork="bridge"
  log-info "Default: Use bridge network."
}

#mkdir -p /mnt/containerdata/zabbix/
#touch /mnt/containerdata/zabbix/checkendpoint.conf

#chmod +x ./get_gpus_info.sh
#cp ./get_gpus_info.sh /mnt/containerdata/zabbix/get_gpus_info.sh

#cp ./monitor-nginx/nginx_requetsPerMin.conf /mnt/containerdata/zabbix/nginx_requetsPerMin.conf

runcmd=$(cat <<__
docker run --name ${conname} --hostname ${conname} --restart always --cpus 2 -m 1GB --memory-swap 1GB \
  --network "${dockerNetwork}" -e ZBX_SERVER_HOST="${server_url}" -e NGINX_IP="${nginx_ip}" \
  --privileged -p "${exposePort}":10050 --user root -e TZ=Asia/Ho_Chi_Minh ${containerIP} \
  -v /mnt/containerdata/zabbix-agent/etc_zabbix:/mnt/containerdata/zabbix-agent/etc_zabbix \
  -v "${nginxDir}":/mnt/containerdata/nginxgen \
  -v /var/run/docker.sock:/var/run/docker.sock -idt "${image}"
__
)

#  -v /mnt/containerdata/zabbix-agent/etc_zabbix:/etc/zabbix \
echo "$runcmd"
eval "$runcmd"
#-v /mnt/containerdata/zabbix-agent/etc_zabbix_zabbix_agentd:/etc/zabbix/zabbix_agentd.d \
#  -v /mnt/containerdata/zabbix-agent/var_lib_zabbix_modules:/var/lib/zabbix/modules \
#  -v /mnt/containerdata/zabbix-agent/var_lib_zabbix_enc:/var/lib/zabbix/enc

#docker cp ./userparameter_nvidia-smi.conf zabbix-agent:/etc/zabbix/zabbix_agentd.d/userparameter_nvidia-smi.conf
#docker restart ${conname}

#[[ ${dockerNetwork} != "bridge" ]] && {
#  docker network connect bridge ${connname}
#}

log-step "Restart zabbix-agent container to apploy nvidia param config. Done."
# TLS related files /var/lib/zabbix/enc
