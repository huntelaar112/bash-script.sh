#!/bin/bash

name=oracledb-volume
sid=CDB1
pdb=pdb1
password="hanoi123"
host_oracle_data=/mnt/containerdata/oracledb/oradata

volumename=oradata
#mkdir -p ${host_oracle_data} && chown -R 54321:54321 ${host_oracle_data}

docker volume create ${volumename}

docker run -idt --hostname ${name} --name ${name} -e TZ=Asia/Ho_Chi_Minh --restart always \
        -e ORACLE_SID=${sid} \
        -e ORACLE_PDB=${pdb} \
        -e ORACLE_PWD=${password} \
        -e ORACLE_CHARACTERSET=AL32UTF8 \
        -v ${volumename}:/opt/oracle/oradata \
        container-registry.oracle.com/database/enterprise:19.3.0.0

#       --ulimit nofile=1024:65536 --ulimit nproc=2047:16384 --ulimit stack=10485760:33554432 --ulimit memlock=3221225472 \
#        -v ${volumename}:/opt/oracle \

##################### tablespace need to put inside /opt/oracle/oradata, if not mount  -v ${volumename}:/opt/oracle \