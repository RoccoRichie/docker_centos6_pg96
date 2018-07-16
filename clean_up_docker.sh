#!/bin/bash

_DOCK=/usr/bin/docker
_ECHO=/bin/echo
_SLEEP=/bin/sleep


check_return_value()
{
    if [ $? -eq 0 ];  then
        ${_ECHO} "INFO:: Step: $1 finished SUCCESSFULLY"
    else
        ${_ECHO} "ERROR:: Step: $1 FAILED..."
    fi
}

docker_prune()
{
    msg="Attempting to prune Docker"
    ${_ECHO} ${msg}
    ${_DOCK} system prune -a

    check_return_value ${msg}
}

remove_stack()
{
    msg="Attempting to remove all HA stack"
    ${_ECHO} ${msg}
    ${_DOCK} stack rm HA
    check_return_value ${msg}
}

remove_images()
{
    msg="Attempting to remove all Docker Images"
    ${_ECHO} ${msg}
    ${_DOCK} image rm -f $(${_DOCK} image ls -a -q)
    check_return_value ${msg}
}

remove_containers()
{
    msg="Attempting to remove all Docker Container"
    ${_ECHO} ${msg}
    ${_DOCK} container rm $(${_DOCK} container ls -a -q)
    check_return_value ${msg}
}

remove_volumes()
{
    msg="Attempting to remove all Docker Volumes"
    ${_ECHO} ${msg}
    ${_DOCK} volume rm $(${_DOCK} volume ls)
    check_return_value ${msg}
}


#MAIN
remove_stack
${_SLEEP} 5
docker_prune
remove_images
remove_containers
remove_volumes