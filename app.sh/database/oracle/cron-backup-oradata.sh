#!/bin/bash

backupDir=~/oraclebackup
oracle_db_container="oracledb_wowcrm"

mkdir -p "${backupDir}"

cd "${backupDir}" && \
docker-backup-volume "${oracle_db_container}" /opt/oracle/oradata && \
find "${backupDir}" -type f -mtime +7 -exec rm {} \;


## chmod +x and  cp this file to /bin
## crontab -e and add 
## -->  0 0 * * * cron-backup-oradata.sh
