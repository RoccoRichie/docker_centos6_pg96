#!/bin/bash

_CLEAR=/usr/bin/clear
_DU='/usr/bin/du -h'
_ECHO=/bin/echo
_SED=/bin/sed

DB="pgloader_db"
BASE_DIR=/var/lib/pgsql/9.6/data/base/


function display_info()
{
    ${_CLEAR}
    ${_ECHO} ""
    ${_ECHO} "************************************************************************"
    ${_ECHO} "DATABASE INFORMATION FOR PGLOADER_DB"
    ${_ECHO} ""

    count_1=$(su - postgres -c "psql -qAt -U postgres -d pgloader_db -c 'SELECT COUNT(*) FROM test_table_1;'")
    count_2=$(su - postgres -c "psql -qAt -U postgres -d pgloader_db -c 'SELECT COUNT(*) FROM test_table_2;'")
    cost_1=$(su - postgres -c "psql -qAt -U postgres -d pgloader_db -c 'EXPLAIN SELECT COUNT(*) FROM test_table_1;'")
    cost_2=$(su - postgres -c "psql -qAt -U postgres -d pgloader_db -c 'EXPLAIN SELECT COUNT(*) FROM test_table_2;'")

    ${_ECHO} "************************************************************************"
    ${_ECHO} "NUMBER OF ROWS"
    ${_ECHO} "¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬"
    ${_ECHO} "Number of Rows in test_table_1:: ${count_1}"
    ${_ECHO} "Number of Rows in test_table_2:: ${count_2}"
    ${_ECHO} ""

    ${_ECHO} "************************************************************************"
    ${_ECHO} "COST OF QUERRIES"
    ${_ECHO} "¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬"
    ${_ECHO} "Cost of Query 1:"
    ${_ECHO} "${cost_1}"
    ${_ECHO} "Cost of Query 2:"
    ${_ECHO} "${cost_2}"
    ${_ECHO} "************************************************************************"
    ${_ECHO} ""

    oid=$(su - postgres -c "psql -qAt -U postgres -d pgloader_db -c\
             'SELECT oid from pg_database WHERE datname='\''pgloader_db'\'';'")
    db_id="$(${_ECHO} -e "${oid}" | sed -e 's/^[[:space:]]*//')"

    ${_ECHO} "Databse ID:: ${oid}"
    ${_ECHO} ""
    ${_ECHO} "Size of pgloader_db Databse::"
    ${_DU} ${BASE_DIR}${db_id}
    ${_ECHO} "************************************************************************"
    ${_ECHO} ""
}

# Main
display_info