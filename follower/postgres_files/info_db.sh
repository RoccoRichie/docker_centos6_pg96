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
    ${_ECHO} "******************************************"
    ${_ECHO} "Number of rows in the pgloader_db database"
    ${_ECHO} ""
    su - postgres -c "psql -U postgres -d pgloader_db -c\
                  'SELECT relname AS \"Table_Name\", n_live_tup as \"Row_Count\"
                  FROM pg_stat_user_tables
                  ORDER BY n_live_tup
                  DESC;'"

    ${_ECHO} ""
    oid=$(su - postgres -c "psql -qAt -U postgres -d pgloader_db -c\
             'SELECT oid from pg_database WHERE datname='\''pgloader_db'\'';'")
    db_id="$(${_ECHO} -e "${oid}" | sed -e 's/^[[:space:]]*//')"

    ${_ECHO} "Databse ID:: ${oid}"
    ${_ECHO} ""
    ${_ECHO} "Size of pgloader_db Databse::"
    ${_DU} ${BASE_DIR}${db_id}
    ${_ECHO} "******************************************"
    ${_ECHO} ""
}

# Main
display_info