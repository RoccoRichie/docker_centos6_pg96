#!/bin/bash

_CLEAR=/usr/bin/clear
_ECHO=/bin/echo
_RMF="/bin/rm -rf"
_SERVICE="/sbin/service"
_SLEEP=/bin/sleep

FAILOVER_TRIGGER_FILE=/backup_dir/pg_failover_trigger
HOST=$(hostname -I)
PG_SERVICE=postgresql-9.6


check_return_value()
{
    if [ $? -eq 0 ];  then
        ${_ECHO} "INFO:: Step: $1 finished SUCCESSFULLY"
    else
        ${_ECHO} "ERROR:: Step: $1 FAILED..."
    fi
}

remove_trigger_file()
{
    ${_ECHO} "Attempting to remove ${FAILOVER_TRIGGER_FILE}"
    ${_RMF} ${FAILOVER_TRIGGER_FILE}
    check_return_value "Attempting to remove ${FAILOVER_TRIGGER_FILE}"
}

get_recovery_status()
{
    ${_ECHO} ""
    ${_ECHO} "************************************************************************"
    ${_ECHO} "FAILOVER THE LEADER"
    ${_ECHO} ""

    is_in_recovery=$(su - postgres -c "psql -U postgres -qAt -c 'select pg_is_in_recovery();'")

    ${_ECHO} "************************************************************************"
    ${_ECHO} "In Recovery Mode"
    ${_ECHO} "¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬"
    if [[ ${is_in_recovery} == "t"  ]]; then
        ${_ECHO} "${HOST} is in recovery mode"
    else
        ${_ECHO} "${HOST} is NOT in recovery mode"
        ${_ECHO} "${HOST} is Now the LEADER"
        #remove_trigger_file
    fi
    ${_ECHO} "************************************************************************"
    ${_ECHO} ""
}

start_stop_postgres()
{
    ${_ECHO} "Attempting to $1 the service PostgreSQL"
    ${_SERVICE} ${PG_SERVICE} $1 >/dev/null 2>&1
    check_return_value "Attempting to $1 the service PostgreSQL"
}


trigger_failover()
{
    ${_ECHO} "Attempting to Failover the leader"
    ${_ECHO} "Attempting to create ${FAILOVER_TRIGGER_FILE}"
    ${_ECHO} "smart" > ${FAILOVER_TRIGGER_FILE}
    check_return_value "Attempting to create ${FAILOVER_TRIGGER_FILE}"
}

# Main
${_CLEAR}
get_recovery_status
trigger_failover
${_SLEEP} 5
start_stop_postgres restart
${_SLEEP} 5
get_recovery_status