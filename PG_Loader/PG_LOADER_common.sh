#!/bin/bash

ECHO=/bin/echo
PG_USER=postgres
PSQL=/usr/bin/psql
LOG_DIR=/var/tmp/pg_loader/
LOG_FILE=postgres_loader.log
DB=pgloader_db

#*****************************************************************************#
#This function creates a log file in the specified location, if the required
#log file doesn't exists. Otherwise updates the existing log file with info
#and error details.
#*****************************************************************************#
function logRotate() {
    if [ -f ${LOG_DIR}/${LOG_FILE} ]; then
        LDATE=`date +[%m%d%Y%T]`
        mv ${LOG_DIR}/${LOG_FILE} ${LOG_DIR}/${LOG_FILE}.${LDATE}
        touch ${LOG_DIR}/${LOG_FILE}
        chmod a+w ${LOG_DIR}/${LOG_FILE}
    else
        if [ ! -d "${LOG_DIR}" ]; then
        mkdir ${LOG_DIR}
        fi
        touch ${LOG_DIR}/${LOG_FILE}
        chmod a+w ${LOG_DIR}/${LOG_FILE}
        chown -R ${PG_USER} ${LOG_DIR}
    fi
}

#*****************************************************************************#
# This function is used for logging all the info and errors
#*****************************************************************************#
function infoLog(){
    LDATE=$(date +[%m%d%Y%T])
    TAG="vxPGresize"
    msg=$1
    logger -s ${LOG_FILE} ${msg}
    $ECHO "$TAG $LDATE $msg" &>>$LOG_FILE
}

#*****************************************************************************#
# This function logs the execution status of a particular process or a command
# $1 refers to the comments passed as argument to checkExitCode function
#*****************************************************************************#
function checkExitCode(){
    if [ $? -eq 0 ];  then
        infoLog "Step: $1 finished SUCCESSFULLY"
        return 0;
    fi
    infoLog "Step: $1 failed. Exiting..."
    exit 1
}

function run_psql_query()
{
    su - $PG_USER -c "$PSQL -U $PG_USER -t -c ${1}"

}

function run_psql_query_on_db()
{
    su - $PG_USER -c "$PSQL -U $PG_USER -d ${1} -c ${2}"

}

function load_data(){

    infoLog "Attempting to Load Data into ${DB}'s: ${1}"
    run_psql_query_on_db ${DB} '"INSERT INTO '"\"'${1}'"\"'
    values ( generate_series(1,'"\"'${2}'"\"'), md5(random()::text));"' >> ${LOG_FILE}

    checkExitCode "Loading Data into ${1}"
}

function get_row_list()
{

    run_psql_query_on_db ${DB} '"
    SELECT relname AS "Table_Name", n_live_tup as "Row_Count"
    FROM pg_stat_user_tables
    ORDER BY n_live_tup
    DESC;"' >> ${LOG_FILE}
}
