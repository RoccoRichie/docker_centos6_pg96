#!/bin/bash

_CAT=/bin/cat
_CHOWN=/bin/chown
_ECHO=/bin/echo
_SERVICE="/sbin/service"
_UNIX_LOGGER="/usr/bin/logger"

APP_ID="HA_FOLLOWER_SERVICES"
FOLLOWER_DIR=/postgres_follower

EX_SSH_CONF=/etc/ssh/sshd_config
NEW_SSH_CONF=${FOLLOWER_DIR}/sshd_config
SHARED_FS="/shared_wals"


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

update_ssh_conf()
{
    logger info "Attempting to append ${EX_SSH_CONF} with ${NEW_SSH_CONF}"
    ${_CAT} ${NEW_SSH_CONF} >> ${EX_SSH_CONF}
    RETVAL=$?
    if [[ ${RETVAL} -ne 0 ]];
    then
        logger error "Failed to append ${EX_SSH_CONF} with ${NEW_SSH_CONF}"
    else
        logger info "Successfully appended ${EX_SSH_CONF} with ${NEW_SSH_CONF}"
    fi
}

start_sshd()
{
    logger info "Attempting to START the service sshd"
    ${_SERVICE} sshd start
    RETVAL=$?
    if [[ ${RETVAL} -ne 0 ]];
    then
        logger error "Failed to start rsyslog sshd"
    else
        logger info "sshd service was started"

    fi
}

#MAIN
start_rsyslog
