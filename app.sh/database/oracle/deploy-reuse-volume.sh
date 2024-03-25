#!/bin/bash

name=oracledb-resuseVolume
sid=CDB1
pdb=pdb1
password="hanoi123"
host_oracle_data=/mnt/containerdata/oracledb/oradata

volumename=test
#mkdir -p ${host_oracle_data} && chown -R 54321:54321 ${host_oracle_data}

#docker volume create ${volumename}

docker run -idt --hostname ${name} --name ${name} -e TZ=Asia/Ho_Chi_Minh --restart always \
        --ulimit nofile=1024:65536 --ulimit nproc=2047:16384 --ulimit stack=10485760:33554432 --ulimit memlock=3221225472 \
        -e ORACLE_SID=${sid} \
        -v ${volumename}:/opt/oracle \
        container-registry.oracle.com/database/enterprise:19.3.0.0