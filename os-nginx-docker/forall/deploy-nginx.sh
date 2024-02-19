#!/bin/bash
set -e
imagebase="sonnt/nginxgen:latest-base"
#imagebase="mannk98/nginxgen:pgb"
connname=nginxgen
docker pull ${imagebase}
docker rm -f ${connname}.old || :
docker rename ${connname}{,.old} &>/dev/null || :

HOSTHOME=/mnt/containerdata/nginxgen
docker stop ${connname}.old || :

docker run --network ocrnetwork --ip 172.172.0.200 \
  -p 443:443 -p 80:80 \
  --restart always \
  -e HOSTHOME=/mnt/hosthome \
  -v ${HOSTHOME}:/mnt/hosthome -e TZ=Asia/Ho_Chi_Minh \
  --cap-add SYS_ADMIN --device /dev/fuse --security-opt "apparmor:unconfined" \
  --cap-add SYS_PTRACE \
  --ipc host \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name ${connname} --hostname ${connname} -itd ${imagebase}

#docker exec -it ${connname} bash
docker network connect bridge ${connname}
#docker cp ./statuslocal.conf nginxgen:/etc/nginx/
docker restart nginxgen
docker ps | grep nginxgen
exitval="$?"
exit "${exitval}"
