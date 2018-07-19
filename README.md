# Dockerfiles - Centos6.6 & PostgreSQL 9.6 #

This image is built on top of Centos 6.6, and has PostgreSQL 9.6 installed.
Clone down the repo from: https://github.com/RoccoRichie/docker_centos6_pg96.git

## Build the images ##
Do the following for both the Postgres leader and follower images: 

Change directory to the relevant Postgres image:

    cd Centos6_Postgres96_HA/leader
    cd Centos6_Postgres96_HA/follower

[A] Build Commands for the Centos 6.6 Postgres 9.6 Images:
    
    docker build --rm -t local/pg96_cos6_ha_leader .
    docker build --rm -t local/pg96_cos6_ha_follower .    

This will create an image with a TAG --> /pg96_cos6_ha_leader or local/pg96_cos6_ha_follower

[B] To keep Consistency with the Dockerfile, TAG the built image as follows:

    docker tag local/pg96_cos6_ha_leader:latest aintgriz/pg96_cos6_ha_leader:0.7
    docker tag local/pg96_cos6_ha_leader:latest aintgriz/pg96_cos6_ha_leader:0.7


Alternatively, get pre-built image from docker hub
Go to the Tags page and find the latest release (e.g. Tag Name 0.7)

    https://hub.docker.com/r/aintgriz/pg96_cos6_ha_leader/tags/
    https://hub.docker.com/r/aintgriz/pg96_cos6_ha_follower/tags/

[A.1] Use docker pull with the latest tag:

    docker pull aintgriz/pg96_cos6_ha_leader:0.7
    docker pull aintgriz/pg96_cos6_ha_follower:0.7

## Build the stack ##
Change directory to outer directory which contains the docker-compose.yml. The docker-compose file contains the definition of our 2 PostgreSQL services (Leader & Follower). 
It contains the ports and volumes we wish to expose and create.
In this example, we are creating a warm standby HA solution for PostgreSQL.
Therefore, each PostgreSQL service will require their own data directory. 
We also create 2 shared file systems (Docker Volumes on our local host).

    cd Centos6_Postgres96_HA/
    
### Create the Stack ###

[C] Deploy Command

We name our stack HA and deploy it with the following command:

    docker stack deploy -c docker-compose.yml HA

Inspect the HA stack:

    docker stack ps HA

When the stack is up and running connect to the container

## Connect to the Containers ##    
### Connect to the PostgreSQL Services ###

Open 2 terminals and execute the following commands to connect to an interactive
terminal for the PostgreSQL services:

[D] Connect to an interactive terminal of the leader:

    docker exec -ti $(docker ps -qf name=HA_postgres_leader) bash
    
[D1] Connect to an interactive terminal of the follower:

    docker exec -ti $(docker ps -qf name=HA_postgres_follower) bash

You enter into the working directory /postgres_leader & /postgres_follower, which contains scripts to:
* Start rsyslog service - for collection of logging
* Initialise the postgres database
* Update customised configurations for postgres
* Set trust for all host base authentication for postgres
* Start the postgres services
* Create a Replicator Role
* Create a dummy database (pgloader_db)
* Generate 3000 rows of Data

[E] Take note of Hostname for both leader and follower

    hostname -I

Usually the IP address will be as follows:
* Leader      --> 10.0.0.4
* Follower    --> 10.0.0.6

These values will then be used to update the following files when prompted:​
* Pg_hba.conf​
* Recovery.conf


[F] Start both Leader and Follower

On Leader pass the IP address of the follower to the start script:

    [root@42b11013f97d postgres_leader]# ./start_postgres_leader.sh 10.0.0.6

On Follower execute the start script:

    [root@42b11013f97d postgres_leader]# ./start_postgres_leader.sh 10.0.0.6


[F1] The Start script on the Leader will do the following:
* Enable rsyslog​
* Initialize the database​
* Copies Customized configurations​
* Sets the required host based authentication​
* Sets Archive mode = on​
* Copies the WALs to shared directory (rsync, cp, etc)​
* Starts PostgreSQL service
* Creates a Replicator Role​
* Creates a dummy database​
* Generates 3000 rows into database

    
Output:
-------

    ************************************************************************
    DATABASE INFORMATION FOR PGLOADER_DB
    
    ************************************************************************
    NUMBER OF ROWS
    ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
    Number of Rows in test_table_1:: 20
    Number of Rows in test_table_2:: 3000
    
    ************************************************************************
    COST OF QUERRIES
    ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
    Cost of Query 1:
    Aggregate  (cost=15.12..15.13 rows=1 width=8)
      ->  Seq Scan on test_table_1  (cost=0.00..14.10 rows=410 width=0)
    Cost of Query 2:
    Aggregate  (cost=43.86..43.87 rows=1 width=8)
      ->  Seq Scan on test_table_2  (cost=0.00..40.89 rows=1189 width=0)
    ************************************************************************
    
    Databse ID:: 16385
    
    Size of pgloader_db Databse::
    7.2M	/var/lib/pgsql/9.6/data/base/16385
    ************************************************************************

This info can also be retrieved by executing the following script in either the Leader or follower:

    # ./info_db.sh
    
[F1] The Start script on the Follower will do the following:
* Enable rsyslog​
* Initialize the database​
* Starts PostgreSQL service

[G] By Executing the following script on the leader will keep a constant load 
on the database for approx 200 seconds:

    [root@942f00239de3 ha_postgres]# ./generate_slow_load.sh -c 200

By using the -c argument and passing a number will create load on the server.
It will create rows of data into a table. -c 200 will generate an additional 
200000 rows into a table, which approximates to an increase in the database of 15MB.

Output:
------

    ************************************************************************
    NUMBER OF ROWS
    ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
    Number of Rows in test_table_1:: 20
    Number of Rows in test_table_2:: 204000
    
    ************************************************************************
    COST OF QUERRIES
    ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
    Cost of Query 1:
    Aggregate  (cost=15.12..15.13 rows=1 width=8)
      ->  Seq Scan on test_table_1  (cost=0.00..14.10 rows=410 width=0)
    Cost of Query 2:
    Aggregate  (cost=4457.61..4457.62 rows=1 width=8)
      ->  Seq Scan on test_table_2  (cost=0.00..3947.49 rows=204049 width=0)
    ************************************************************************
    
    Databse ID:: 16394
    
    Size of pgloader_db Databse::
    22M	/var/lib/pgsql/9.6/data/base/16394
    ************************************************************************

### Start Back Up on Follower ###
[H] Trigger the backup script on the Follower and pass the IP address of the Leader:

    [root@d369b838d6b5 postgres_follower]# ./backup_and_sync.sh 10.0.0.6

By executing the backup_script the following will be done:
* Stops postgres on the follower​
* Creates a recovery.conf and passes in the leaders hostname​
* Triggers a backup check point on the WALs​
* Takes a backup of leader and generates a tar file in the shared file system (pg_base_backup)​
* untar the backup and replaces the follower data directory with the backup​
* Restarts postgres​
* Replays the WALs from the check pointed WAL​
* Sync all WALs from now on​


Output:
------
    ************************************************************************
    DATABASE INFORMATION FOR PGLOADER_DB
    
    ************************************************************************
    NUMBER OF ROWS
    ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
    Number of Rows in test_table_1:: 20
    Number of Rows in test_table_2:: 204000
    
    ************************************************************************
    COST OF QUERRIES
    ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
    Cost of Query 1:
    Aggregate  (cost=15.12..15.13 rows=1 width=8)
      ->  Seq Scan on test_table_1  (cost=0.00..14.10 rows=410 width=0)
    Cost of Query 2:
    Aggregate  (cost=4457.61..4457.62 rows=1 width=8)
      ->  Seq Scan on test_table_2  (cost=0.00..3947.49 rows=204049 width=0)
    ************************************************************************
    
    Databse ID:: 16394
    
    Size of pgloader_db Databse::
    22M	/var/lib/pgsql/9.6/data/base/16394
    
    ************************************************************************
    Log Delay
    ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
    Log Delay:: 0
    ************************************************************************

If a trigger file is created, then the follower can be promoted to Leader

[I] Included is a text file which contains useful commands, which show location of conf files,
    PSQL querries, start/stop postgres service, etc

    # cat useful_commands.txt

[J] Logs can be viewed under /var/log/messages

    # less /var/log/messages
    
    
Keep on Trucking....

:sunglasses: