#!/bin/bash

HOST_LEADER=$1

_CAT=/bin/cat
_CHOWN=/bin/chown
_CP="/bin/cp -i"
_ECHO=/bin/echo
_PG_BAK=/usr/bin/pg_basebackup
_RMF="/bin/ -rf"
_SERVICE="/sbin/service"
_SU=/bin/su
_UNIX_LOGGER="/usr/bin/logger"

APP_ID="PG_BUS"
FOLLOWER_DIR=/postgres_follower
PGCONF=/var/lib/pgsql/9.6/data/postgresql.conf
PGDATA=/var/lib/pgsql/9.6/data/
PGHBA=/var/lib/pgsql/9.6/data/pg_hba.conf
PG_SERVICE=postgresql-9.6
PG_USER="postgres"
PG_REPLICATOR="replicator"
RECOVER_CONF=${FOLLOWER_DIR}/recovery.conf
SHARED_FS_WALS="/shared_wals"
SHARED_FS_BACKUP="/backup_dir"


logger()
{
    if [ $# -eq 2 ]; then
        case $1 in
        info)
          ${_UNIX_LOGGER} -s -p info -t ${APP_ID} [INFO]: "$2"
        ;;
        error)
          ${_UNIX_LOGGER} -s -p error -t ${APP_ID} [ERROR]: "$2"
        ;;
        debug)
          ${_UNIX_LOGGER} -s -p debug -t ${APP_ID} [DEBUG]: "$2"
        ;;
        warning)
          ${_UNIX_LOGGER} -s -p warn -t ${APP_ID} [WARNING]: "$2"
        esac
    fi
}

check_for_argument()
{
    if [ $# -eq 0 ]
      then
        logger error "Leader Host must be provided"
        logger error "Execute script by passing ip address of Host"
        logger debug "E.G. ./$0 10.0.0.4"
        exit 1
    fi
}

check_exit_code()
{
    if [ $? -eq 0 ];  then
        logger info "Step: $1 finished SUCCESSFULLY"
    else
        logger error "Step: $1 FAILED..."
    fi
}

start_stop_postgres()
{
    logger info "Attempting to $1 the service PostgreSQL"
    ${_SERVICE} ${PG_SERVICE} $1 >/dev/null 2>&1
    check_exit_code "Attempting to $1 the service PostgreSQL"
}

backup_leader()
{
    logger info "Attempting to backup PostgreSQL Leader as a tar file"
    ${_SU} - ${PG_USER} -c "${_PG_BAK} -h ${HOST_LEADER} -U ${PG_REPLICATOR} \
    -Ft -x -D - > /${SHARED_FS_BACKUP}/leader_bkup.tar"
    check_exit_code "Attempting to backup PostgreSQL Leader"
}


clear_follower_data()
{
    logger info "Attempting to clear FOLLOWER ${PGDATA}"
    ${_RMF} ${PGDATA}/*
    check_exit_code "Attempting to clear FOLLOWER ${PGDATA}"
}

unpack_backup()
{
    logger info "Attempting to unpack Leader backup to FOLLOWER ${PGDATA}"

    check_exit_code "Attempting to unpack Leader backup to FOLLOWER ${PGDATA}"
}

update_recovery_conf_with_Host()
{
    logger info "Attempting to update ${RECOVER_CONF} with ${HOST_LEADER}"
    echo "primary_conninfo = 'host=${HOST_LEADER} user={PG_REPLICATOR}'" \
    >> ${RECOVER_CONF}
    check_exit_code "Attempting to update ${RECOVER_CONF} with ${HOST_LEADER}"
}

copy_recovery_file()
{
    logger info "Attempting to copy ${RECOVER_CONF} to ${PGDATA}"
    ${_CP} ${RECOVER_CONF} ${PGDATA}
    check_exit_code "Attempting to copy ${RECOVER_CONF} to ${PGDATA}"
}

#MAIN

# TODO: Stop Postgres
# TODO: PG_BASE_BACKUP to shared fs --> /backup_dir
# TODO: Remove or Move existing files from follower $PGDATA
# TODO: sync the files into follower $PGDATA
# TODO: copy the recovery.conf to follower $PGDATA
# TODO: check the recovery command - rsync maybe better than cp
# TODO: check if we need hot_standby = on in $PGDATA/postgresql.conf
# TODO: Start Postgres
check_for_argument
start_stop_postgres stop
#backup_leader
#clear_follower_data
#sync_follower
#insert_recovery_file
#reconfig_follower
#start_stop_postgres start
