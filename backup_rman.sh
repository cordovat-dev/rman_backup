#!/bin/bash
if [ "$1" == "1" ];then
        export BACKUPLEVEL=1   
else
        export BACKUPLEVEL=0
fi

if [ -n "$2" ];then
        if [ $(echo $2|wc -c) -gt 20 ];then
                echo "Etiqueta demasiado larga, no debe exceder los 20 caracteres"
                exit 1
        fi
        export ETIQUETA="TAG ${2}_LEVEL_${BACKUPLEVEL}"
else
        export ETIQUETA=""
fi

export PATH=$PATH:$HOME/bin
export HOME=/apl/oracle/product/oracle9
export ORACLE_HOME=/apl/oracle/product/oracle9/9.2.0.8
export ORACLE_PATH=$ORACLE_HOME/bin
export PATH=/usr/bin:${PATH}:${ORACLE_HOME}/bin
export ORACLE_SID=db_instance
export USERNAME=oracle
export RMANREPO=rman_repo_instance
export pass=$ORACLE_HOME/dbs/.pass
export DATE=`date +%d-%b-%Y-%HH-%MM`
export ruta_log="/ora/backups/db_instance/backup_${ORACLE_SID}_${DATE}.log"
export NLS_DATE_FORMAT='dd-mon-yyyy hh24:mi:ss'
bzip2 /ora/archives/${ORACLE_SID}/*.arc
rman target / catalog backup_user/$(cat $pass)@${RMANREPO} << EOF | tee ${ruta_log}
set echo on;
report schema;
show all;
backup incremental level=${BACKUPLEVEL} database ${ETIQUETA};
report need backup;
report unrecoverable;
report obsolete;
list backup;
list backup summary;
delete noprompt obsolete;
crosscheck backupset;
delete noprompt expired backup;
exit;
EOF

