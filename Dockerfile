FROM postgres:latest

ENV POSTGRES_PASSWORD postgres

WORKDIR /

COPY initdb/01_init.sh ./docker-entrypoint-initdb.d

RUN chmod a+x ./docker-entrypoint-initdb.d/01_init.sh
RUN apt-get update
RUN apt-get -y install jq