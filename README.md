Command to Build the Centos 6.6 Base Image:

docker build --rm -t local/centos6-baseimage .

This will create an image with a TAG --> local/centos6-baseimage

To run the container:

docker run --rm -it aintgriz/centos6-postgres96:0.1 bash

[root@fc412459de57 app]# su - postgres -c "psql -U postgres -c '\l'"
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(3 rows)
