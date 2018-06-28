#!/bin/bash

source PG_LOADER_common.sh

COUNTER=100

function apply_load(){

    for ((i=0; i<=$COUNTER; i++));
    do
        load_data test_table_2 100000
        infoLog "Row List AFTER Applying Load Number #$i"
        get_row_list
    done
}

while getopts c: option
do
 case "${option}"
 in
 c) COUNTER=${OPTARG};;
 esac
done

logRotate
infoLog "Row List BEFORE Applying Load"
get_row_list
time apply_load
