#!/bin/bash

## cp file dump (export.dmp) to container:/opt/oracle/admin/CDB1/dpdump first

DB_USERNAME="system"
DB_PASSWORD="hanoi123"
DB_HOST="localhost"
DB_PORT="1521"
DB_SID="CDB1"  # SID or service name of your Oracle database

DB_USER="app_crm"
DB_USER_PASS="Gmo#2024"
DB_PDB="pdb1"
TABLE_SPACE_NAME=wocrm

DUMP_DIRECTORY="/opt/oracle/admin/CDB1/dpdump"
TABLE_SPACE_DATAFILE="/opt/oracle/oradata/wocrm.dbf"

# create user, grant access
sqlplus ${DB_USERNAME}/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SID} <<EOF
ALTER SESSION SET CONTAINER = ${DB_PDB};
CREATE USER ${DB_USER} IDENTIFIED BY ${DB_USER_PASS};
GRANT CONNECT, RESOURCE, DBA TO ${DB_USER};
exit
EOF

# create table space
sqlplus ${DB_USER}/${DB_USER_PASS}@${DB_HOST}:${DB_PORT}/${DB_PDB} <<EOF
CREATE TABLESPACE ${TABLE_SPACE_NAME} DATAFILE "${TABLE_SPACE_DATAFILE}" SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;
CREATE DIRECTORY DUMPDIRECTORY AS ${DUMP_DIRECTORY};
exit
EOF

# sudo docker cp ./export.dmp oracledb-volume:/opt/oracle/admin/CDB1/dpdump
impdp app_crm/Gmo#2024@pdb1 directory=DUMPDIRECTORY dumpfile=export.dmp logfile=import.log


# rebuild in valid objects
#sqlplus ${DB_USERNAME}/${DB_USER_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SID} <<EOF
#@/opt/oracle/product/19c/dbhome_1/rdbms/admin/utlrp.sql
#exit
#EOF
