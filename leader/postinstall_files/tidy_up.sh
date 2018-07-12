#!/bin/bash

_RMF="/bin/rm -rf"
_SERVICE="/sbin/service"
_UNIX_LOGGER="/usr/bin/logger"

APP_ID="PG_TIDIER"
PGDATA=/var/lib/pgsql/9.6/data/
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

check_return_value()
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
    check_return_value "Attempting to $1 the service PostgreSQL"
}

clean_pgdata()
{
    logger info "Attempting to clear ${PGDATA}"
    ${_RMF} ${PGDATA}/*
    check_return_value "Attempting to clear ${PGDATA}"
}

clean_wals()
{
    logger info "Attempting to clear ${SHARED_FS_WALS}"
    ${_RMF} ${SHARED_FS_WALS}/*
    check_return_value "Attempting to clear ${SHARED_FS_WALS}"
}

clean_backup()
{
    logger info "Attempting to clear ${SHARED_FS_BACKUP}"
    ${_RMF} ${SHARED_FS_BACKUP}/*
    check_return_value "Attempting to clear ${SHARED_FS_BACKUP}"
}

#MAIN
start_stop_postgres stop
clean_pgdata
clean_wals
clean_backup
