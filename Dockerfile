FROM centos:6.6
ENV container docker

VOLUME [ "/sys/fs/cgroup" ]

RUN yum -y install httpd; service httpd start
EXPOSE 80

CMD ["/usr/sbin/init"]

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
ENV LANG en_US.utf8

ENV PG_MAJOR 9.6
ENV PG_VERSION 9.6.9
ENV PG_SHA256 b97952e3af02dc1e446f9c4188ff53021cc0eed7ed96f254ae6daf968c443e2e

# Download the Required Postgres RPMs:

# Get the pgdg package which contains the PostgreSQL 96 rpms for Centos6:
RUN rpm -ivh https://yum.postgresql.org/9.6/redhat/rhel-6.9-x86_64/pgdg-centos96-9.6-3.noarch.rpm

# Install PostgreSQL 9.6
RUN yum -y install postgresql96 postgresql96-server postgresql96-libs postgresql96-contrib; yum clean all

# Install additional Software
# RUN yum -y update && yum -y install vim

# Initialise the db
RUN service postgresql-9.6 initdb

# Start the PostgreSQL service
RUN service postgresql-9.6 start

RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 2777 /var/run/postgresql

ENV PATH $PATH:/usr/lib/postgresql/$PG_MAJOR/bin
ENV PGDATA /var/lib/pgsql/9.6/data/
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA" # this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
VOLUME /var/lib/pgsql/9.6/data/

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

EXPOSE 5432

# Build Command:
# docker build --rm -t local/centos6-baseimage .