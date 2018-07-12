#!/bin/bash

HOST_LEADER=$1
echo ${HOST_LEADER}

_CAT=/bin/cat
_CHMOD=/bin/chmod
_CHOWN=/bin/chown
_CP="/bin/cp"
_ECHO=/bin/echo
_PG_BAK=/usr/bin/pg_basebackup
_RMF="/bin/rm -rf"
_SERVICE="/sbin/service"
_SU=/bin/su
_TAR=/bin/tar
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
    if [ -z ${HOST_LEADER} ]; then
        logger error "Leader Host must be provided"
        logger error "Execute script by passing ip address of Host"
        logger debug "E.G. --> $0 10.0.0.4"
        exit 1
    fi
}

check_return_value()
{
    if [ $? -eq 0 ];  then
        logger info "Step: $1 finished SUCCESSFULLY"
    else
        logger error "Step: $1 FAILED..."
    fi
}

start_rsyslog()
{
    logger info "Attempting to START the service rsyslog"
    ${_SERVICE} rsyslog start
    RETVAL=$?
    if [[ ${RETVAL} -ne 0 ]];
    then
        logger error "Failed to start rsyslog service"
    else
        ${_ECHO} "" > /var/log/messages
        logger info "rsyslog service was started"
        logger debug "Log messages can now be viewed in /var/log/messages"

    fi
}

start_stop_postgres()
{
    logger info "Attempting to $1 the service PostgreSQL"
    ${_SERVICE} ${PG_SERVICE} $1 >/dev/null 2>&1
    check_return_value "Attempting to $1 the service PostgreSQL"
}

backup_leader()
{
    logger info "Attempting to backup PostgreSQL Leader as a tar file"
    ${_SU} - ${PG_USER} -c "${_PG_BAK} -h ${HOST_LEADER} -U ${PG_REPLICATOR} \
    -Ft -x -D - > ${SHARED_FS_BACKUP}/leader_bkup.tar"
    check_return_value "Attempting to backup PostgreSQL Leader"
}


clear_follower_data()
{
    logger info "Attempting to clear FOLLOWER ${PGDATA}"
    ${_RMF} ${PGDATA}/*
    check_return_value "Attempting to clear FOLLOWER ${PGDATA}"
}

unpack_backup()
{
    logger info "Attempting to unpack Leader backup to FOLLOWER ${PGDATA}"
    ${_SU} - ${PG_USER} -c "${_TAR} x -v -C ${PGDATA} -f \
    ${SHARED_FS_BACKUP}/leader_bkup.tar" >/dev/null 2>&1
    check_return_value "Attempting to unpack Leader backup to FOLLOWER ${PGDATA}"
}

update_recovery_conf_with_Host()
{
    logger info "Attempting to update ${RECOVER_CONF} with ${HOST_LEADER}"
    echo -e "\nprimary_conninfo = 'host=${HOST_LEADER} user=${PG_REPLICATOR}'" \
    >> ${RECOVER_CONF}
    check_return_value "Attempting to update ${RECOVER_CONF} with ${HOST_LEADER}"
}

copy_recovery_file()
{
    logger info "Attempting to copy ${RECOVER_CONF} to ${PGDATA}"
    ${_CP} ${RECOVER_CONF} ${PGDATA}
    check_return_value "Attempting to copy ${RECOVER_CONF} to ${PGDATA}"
}

change_follower_permissions()
{
    logger info "Attempting to change permissions to 700 of ${PGDATA}"
    ${_CHMOD} 700 ${PGDATA}
    check_return_value "Attempting to change permissions to 700 of ${PGDATA}"
}

#MAIN
check_for_argument
start_rsyslog
start_stop_postgres stop
backup_leader
clear_follower_data
unpack_backup
update_recovery_conf_with_Host
copy_recovery_file
change_follower_permissions
start_stop_postgres start
