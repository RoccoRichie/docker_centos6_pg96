FROM centos:6.6
MAINTAINER The CentOS Project <cloud-ops@centos.org>

ENV container docker

VOLUME [ "/sys/fs/cgroup" ]

# Open Ports in the Container
EXPOSE 22 80 873 5432 6432

# Install additional Software
# Issue with installing vim $ openssh, ignore checksum
RUN yum -y install httpd; service httpd start
RUN yum -y install vim rsyslog rsync tar > /dev/null 2>&1; yum clean all

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

RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 2777 /var/run/postgresql

ENV PATH $PATH:/usr/pgsql-9.6/bin/
ENV PGDATA /var/lib/pgsql/9.6/data/
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA" # this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
VOLUME /var/lib/pgsql/9.6/data/

# Set the working directory to /app
WORKDIR /postgres_leader

# Copy the current directory contents into the container at /app
ADD /postinstall_files/ /postgres_leader

# Append custom configs params into default postgresql.conf
RUN chown postgres:postgres leader_hba.conf
RUN chown postgres:postgres leader_postgres.conf

RUN chmod +x create_db.sh replicator_role_create.sh generate_load.sh
RUN chmod +x health_check.sh info_db.sh start_postgres_leader.sh tidy_up.sh

CMD ["/bin/bash", "health_check.sh"]
