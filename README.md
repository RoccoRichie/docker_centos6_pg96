This image is built on top of Centos 6.6, and has PostgreSQL 9.6 installed.

Command to Build the Centos 6.6 Base Image:

docker build --rm -t local/centos-pg96 .

This will create an image with a TAG --> local/centos6-baseimage

To run the container:

docker run --rm -it local/centos-pg96:latest bash

Alternatively, get pre-built image from docker hub
Go to the Tags page and find the latest release (e.g. Tag Name 0.3)
https://hub.docker.com/r/aintgriz/centos6-postgres96/tags/

Use docker pull with the latest tag:
docker pull aintgriz/centos6-postgres96:0.3

To Run interactive shell into this pulled image:
docker run --rm -it aintgriz/centos6-postgres96:0.3 bash

You enter into the working directory ha_postgres, which contains scripts to
* Start rsyslog service - for collection of logging
* Initialise the postgres database
* Update customised configurations for postgres
* Set trust for all host base authentication for postgres
* Start the postgres services

Execute the following script:
* [root@942f00239de3 ha_postgres]# ./start_postgres.sh


There is also scripts to create a dummy database, which is used to add a constant load to it.
Run the follwoing scripts:
* [root@942f00239de3 ha_postgres]# ./create_db.sh

Output:

Number of rows in the pgloader_db database

test_table_1: 20
test_table_2: 0

Databse ID:: 16399

Size of pgloader_db Databse::
7.0M	/var/lib/pgsql/9.6/data/base/16399

By Executing the following script:
* [root@942f00239de3 ha_postgres]# ./generate_load.sh -c 4

By using the -c argument and passing a number will create load on the server.
It will create rows of data into a table. -c 4 will generate 500000 rows into a table,
which approximates to an increase in the database of 35MB.

Output:

Number of rows in the pgloader_db database

test_table_1: 20
test_table_2: 500000

Databse ID:: 16399

Size of pgloader_db Databse::
44M	/var/lib/pgsql/9.6/data/base/16399

Included is a text file which contains useful commands, which show location of conf files,
PSQL querries, start/stop postgres service, etc

Logs can be viewed under /var/log/messages