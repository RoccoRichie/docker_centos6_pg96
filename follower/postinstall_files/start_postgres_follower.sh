#!/bin/bash

_CAT=/bin/cat
_CHOWN=/bin/chown
_ECHO=/bin/echo
_SERVICE="/sbin/service"
_UNIX_LOGGER="/usr/bin/logger"

APP_ID="PG_HA_FOLLOWER"
FOLLOWER_DIR=/postgres_follower
NEW_CONF=${FOLLOWER_DIR}/follower_postgres.conf
NEW_HBA=${FOLLOWER_DIR}/follower_hba.conf
PGCONF=/var/lib/pgsql/9.6/data/postgresql.conf
PGDATA=/var/lib/pgsql/9.6/data/
PGHBA=/var/lib/pgsql/9.6/data/pg_hba.conf
PG_SERVICE=postgresql-9.6
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

update_conf_files()
{
    logger info "Attempting to append ${PGCONF} with ${NEW_CONF}"
    ${_CAT} ${NEW_CONF} >> ${PGCONF}
    RETVAL=$?
    if [[ ${RETVAL} -ne 0 ]];
    then
        logger error "Failed to append ${PGCONF} with ${NEW_CONF}"
    else
        logger info "Successfully appended ${PGCONF} with ${NEW_CONF}"
    fi

    logger info "Attempting to replace ${PGHBA} with ${NEW_HBA}"
    ${_CAT} ${NEW_HBA} > ${PGHBA}
    RETVAL=$?
    if [[ ${RETVAL} -ne 0 ]];
    then
        logger error "Failed to replace ${PGHBA} with ${NEW_HBA}"
    else
        logger info "Successfully replaced ${PGHBA} with ${NEW_HBA}"
    fi
}

initialise_db()
{
    logger info "${PGDATA} is empty...Initialising Database"
    logger info "Attempting to initdb the service PostgreSQL"
    retval=$(${_SERVICE} ${PG_SERVICE} initdb)
    if [[ ${retval} = *"FAILED"* ]];
    then
        logger error "Failed to initialise PostgreSQL service"
    else
        logger info "PostgreSQL service was initialised"
    fi
    update_conf_files
}

start_postgres()
{
    if [[ ! -d  ${PGDATA}/base ]]; then
        initialise_db
    fi

    logger info "Attempting to START the service PostgreSQL"
    ${_SERVICE} ${PG_SERVICE} start >/dev/null 2>&1
    RETVAL=$?
    if [[ ${RETVAL} -ne 0 ]];
    then
        logger error "Failed to start PostgreSQL service"
        logger debug "Investigate the log file:: cat /var/lib/pgsql/9.6/pgstartup.log"
        logger debug "Investigate the log file:: cat /var/lib/pgsql/9.6/data/pg_log/postgresql-"
    else
        logger info "PostgreSQL service was started."
    fi
}

change_ownership_sharedfs()
{
    logger info "Attempting to change ownership of ${SHARED_FS_WALS} directory to postgres"
    ${_CHOWN} postgres:postgres ${SHARED_FS_WALS}
    RETVAL=$?
    if [[ ${RETVAL} -ne 0 ]];
    then
        logger error "Failed to change ownership of ${SHARED_FS_WALS} directory to postgres"
    else
        logger info "Successfully changed ownership of ${SHARED_FS_WALS} directory to postgres"
    fi

    ${_CHOWN} postgres:postgres ${SHARED_FS_BACKUP}
    RETVAL=$?
    if [[ ${RETVAL} -ne 0 ]];
    then
        logger error "Failed to change ownership of ${SHARED_FS_BACKUP} directory to postgres"
    else
        logger info "Successfully changed ownership of ${SHARED_FS_BACKUP} directory to postgres"
    fi
}

#MAIN
start_rsyslog
change_ownership_sharedfs
start_postgres
