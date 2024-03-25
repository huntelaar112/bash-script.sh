#!/bin/bash
{
source `which logshell`
threshold=${THRESHOLD:-75}
interval=$((60*10))
files=$(mktemp)
chunkfiles=$(mktemp)
chunks=500

function cleanup(){
    rm -f "${files}" "${chunkfiles}"
}
trap "cleanup" EXIT ERR

log-info "Wait for SSD to use too ${threshold} percents"
log-info "File list: $files"
log-info "chunkfiles: $chunkfiles"

while :; do
used=$(df -h /dev/sda4 | tail -n 1 | awk '{print $5}' | grep -oEe '[0-9]+')
(( used > threshold )) && {
    log-step "Find the files created older than 30 days (Save to ${files})..."
    find /mnt/containerdata/./*/saved_images/ -mtime +30 -type f > "${files}"

    log-run "Synchronize files to server backup...."
    cnt=0
    nlines=$(wc -l < "${files}")
    while read line; do
        ((cnt++))
        if (( cnt % chunks == 0 || cnt >= nlines )); then
            log-run "File transmission from $((cnt - chunks + 1)) ${cnt} ..."
            rsync --bwlimit=$((1024*15)) --no-i-r -ziPR --compress-level=9  --info=progress2 --remove-source-files --files-from=${chunkfiles} / backup:/media/gmo/DATA/data_backup/saveimagesSTGVN/
            > "${chunkfiles}"
        else
            echo "$line" >> "${chunkfiles}"
        fi
    done < "${files}"
    log-step "done"
    log-info "Wait for SSD to use too ${threshold} percents (interval check $interval seconds)"
}
sleep ${interval}
done
 } |& tee -a /tmp/backup.log

# : "-ahrv  --compress-level" THRESHOLD=65 backup-prodvn --progress
# docker volume rm $(docker volume ls -qf dangling=true)
