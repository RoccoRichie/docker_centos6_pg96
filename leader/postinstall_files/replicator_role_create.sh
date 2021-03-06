#!/bin/bash

source common_library

DB_ROLE=replicator

check_return_value()
{
    if [ $? -eq 0 ];  then
        logger info "Step: $1 finished SUCCESSFULLY"
    else
        logger error "Step: $1 FAILED..."
    fi
}

#**************************************************************************
# This function creates the replication role <replicator>.
# Connection Limit sets a limit for the number of connections for the new user.
# The value 5 is sufficient for replication purposes.
# CREATE ROLE replicator WITH REPLICATION CONNECTION LIMIT 5 LOGIN
#**************************************************************************
create_role()
{
    ${_ECHO} " " > ${LOG_FILE}
    infoLog "Dropping role if it EXISTS : ${DB_ROLE}"
    run_psql_query '"DROP ROLE IF EXISTS '${DB_ROLE}';"' >> ${LOG_FILE}

    infoLog "Attempting to create ${DB_ROLE} role"
    run_psql_query '"CREATE ROLE '"\"'${DB_ROLE}'"\"' WITH REPLICATION CONNECTION LIMIT 5 LOGIN;"' >> ${LOG_FILE}

    check_return_value "Creating role ${DB_ROLE}"
}
create_role