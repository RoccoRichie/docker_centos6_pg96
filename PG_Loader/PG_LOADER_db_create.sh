#!/bin/bash

source PG_LOADER_common.sh

#**************************************************************************
# This function creates the <vxfs_test_db> db, if database doesn't exists
#**************************************************************************
function create_db(){

    $ECHO " " > ${LOG_FILE}
    infoLog "Dropping Test database if it EXISTS : ${DB}"
    run_psql_query '"DROP DATABASE IF EXISTS '${DB}';"' >> ${LOG_FILE}

    infoLog "Attempting to create ${DB} database"
    run_psql_query '"CREATE DATABASE '"\"'${DB}'"\"' WITH OWNER ='"\"'${PG_USER}'"\"' ENCODING ='\''UTF8'\''
    TABLESPACE= pg_default LC_COLLATE ='\''en_US.UTF-8'\'' LC_CTYPE ='\''en_US.UTF-8'\''
    CONNECTION LIMIT =-1;"' >> ${LOG_FILE}

    checkExitCode "Creating database ${DB}"
}

function create_table(){

    infoLog "Attempting to connect to ${DB}"
    run_psql_query  '"\c '${DB}'"' >> ${LOG_FILE}

    infoLog "Attempting to create Table: ${1}"
    run_psql_query_on_db ${DB} '"CREATE TABLE IF NOT EXISTS '"\"'${1}'"\"'
    ( id int, md5Number char(40)); "' >> ${LOG_FILE}

    checkExitCode "Creating Table ${1}"
}


create_db
create_table test_table_1
create_table test_table_2
load_data test_table_1 20
