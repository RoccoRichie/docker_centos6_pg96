#!/bin/bash

source common_library

COUNTER=100

apply_load()
{
    for ((i=0; i<=$COUNTER; i++));
    do
        load_data test_table_2 1000
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

infoLog "Row List BEFORE Applying Load"
get_row_list
time apply_load
sleep 1

source info_db.sh
