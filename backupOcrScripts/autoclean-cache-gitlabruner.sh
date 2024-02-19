#!/bin/bash
{
  source $(which logshell)
  threshold=${THRESHOLD:-80}
  interval=$((60 * 30))
  files=$(mktemp)
  function cleanup() {
    rm -f "${files}"
  }
  trap "cleanup" EXIT ERR
  log-info "Wait for SSD to use too ${threshold} percents or Remove cache volume older than 4 weeks."
  log-info "Old cached folders list: $files"

  while :; do
    used=$(df -h /dev/vdb | tail -n 1 | awk '{print $5}' | grep -oEe '[0-9]+') # %disk
    ((used > threshold)) && {
      docker volume rm $(docker volume ls -qf dangling=true)
      log-step "done"
      log-info "Wait for /dev/vdb to use too ${threshold} percents (interval check $interval seconds)"
    }

#    log-step "Find the cache created older than 2 weeks (Save to ${files})..."
#    find /data/docker-storage/volumes -mtime +14 -type d >"${files}"
#    while read line; do
#      rm -rf "${line}"
#    done <"${files}"

    sleep ${interval}
  done
} |& tee -a /tmp/removeCacheJobContainer.log