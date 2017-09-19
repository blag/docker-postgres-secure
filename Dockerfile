FROM postgres:9.6
# FROM postgres:9.6-alpine

# RUN apk add --update bash postgresql
# RUN apk add --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted postgis

ENV PG_MAJOR 9
ENV PG_MINOR 6

ENV PGIS_MAJOR 2
ENV PGIS_MINOR 3

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get -o Dpkg::Options::="--force-confold" upgrade -y
RUN locale-gen en_US.UTF-8
RUN (echo 146; echo 3) | dpkg-reconfigure locales
RUN cat /etc/default/locale
RUN apt-get install -y postgresql-${PG_MAJOR}.${PG_MINOR}-postgis-${PGIS_MAJOR}.${PGIS_MINOR} \
                       postgresql-${PG_MAJOR}.${PG_MINOR}-postgis-${PGIS_MAJOR}.${PGIS_MINOR}-scripts

RUN apt-get install -y curl libsnappy-dev autoconf automake git-core libtool pkg-config \
                       postgresql-${PG_MAJOR}.${PG_MINOR}-postgis-${PGIS_MAJOR}.${PGIS_MINOR} \
                       postgresql-${PG_MAJOR}.${PG_MINOR}-postgis-${PGIS_MAJOR}.${PGIS_MINOR}-scripts \
                       postgresql-${PG_MAJOR}.${PG_MINOR}-ip4r \
                       postgresql-${PG_MAJOR}.${PG_MINOR}-pgmp \
                       postgresql-${PG_MAJOR}.${PG_MINOR}-pgrouting \
                       postgresql-${PG_MAJOR}.${PG_MINOR}-powa \
                       postgresql-${PG_MAJOR}.${PG_MINOR}-unit

# RUN mkdir /var/run/libpostal
# RUN git clone https://github.com/openvenues/libpostal.git && cd libpostal && \
#     ./bootstrap.sh && \
#     ./config --datadir=/var/run/libpostal && \
#     make && \
#     make install && \
#     ldconfig

# RUN git clone https://github.com/pramsey/pgsql-postal.git && \
#     make && \
#     make install

ADD 0001_init.sh /docker-entrypoint-initdb.d/
