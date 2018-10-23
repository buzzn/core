#!/usr/bin/env bash

file=$1
schema=$2

[[ -z $POSTGRES_HOST ]] && echo "Please set POSTGRES_HOST environment variable" && exit 1
[[ -z $POSTGRES_USER ]] && echo "Please set POSTGRES_USER environment variable" && exit 1
[[ -z $MYSQL_HOST ]] && echo "Please set MYSQL_HOST environment variable" && exit 1
[[ -z $MYSQL_USER ]] && echo "Please set MYSQL_USER environment variable" && exit 1
[[ -z $POSTGRES_PASSWORD ]] && echo "Please set POSTGRES_PASSWORD environment variable" && exit 1
[[ -z $MYSQL_PASSWORD ]] && echo "Please set MYSQL_PASSWORD environment variable" && exit 1

which pgloader 2&> /dev/null
[[ $? -eq 2 ]] && echo "Please install pgloader. https://pgloader.io/" && exit 1
[[ ! -z $(pgloader --version | grep "3.5.2") ]] && echo "pgloader version 3.5.2 has a bug, use 3.5.1 instead if it fails on your system. https://github.com/dimitri/pgloader/issues/810"

echo "Will load into this schema: ${schema}"

cat ${file} | sed -e 's/NOT NULL DEFAULT CURRENT_TIMESTAMP/NOT NULL/' -e 's/NULL DEFAULT CURRENT_TIMESTAMP/NULL/' -e 's/`datum` timestamp/`datum` varchar(32)/' -e 's/NULL ON UPDATE CURRENT_TIMESTAMP/NULL/' -e 's/`timestamp` timestamp/`timestamp` varchar(32)/' -e "s/DEFAULT 'SLP'//" -e 's/`vertragsdatum` date/`vertragsdatum` varchar(16)/' -e 's/`datum` date /`datum` varchar(16) /' -e "s/NOT NULL DEFAULT '0'/NULL/" -e 's/date NOT NULL/varchar(16) NULL/' > ${file}.sql

echo "mysql: drop (old) database ${schema}"
echo "drop database if exists ${schema};" | mysql -u $MYSQL_USER -h $MYSQL_HOST --password=$MYSQL_PASSWORD

echo "mysql: create database ${schema}"
echo "create database ${schema};" | mysql -u $MYSQL_USER -h $MYSQL_HOST --password=$MYSQL_PASSWORD


echo "mysqlimport ${schema}"
mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD < ${file}.sql

echo "pg drop create ${schema}"
PGPASSWORD=$POSTGRES_PASSWORD dropdb -h $POSTGRES_HOST -U $POSTGRES_USER --if-exists ${schema}
PGPASSWORD=$POSTGRES_PASSWORD createdb -h $POSTGRES_HOST -U $POSTGRES_USER ${schema}

echo "convert mysql to pg"
PGPASSWORD=$POSTGRES_PASSWORD pgloader -v mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOST/${schema} postgresql://$POSTGRES_USER@$POSTGRES_HOST/${schema}

PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -d ${schema} -c "ALTER DATABASE ${schema} SET search_path TO ${schema}, public;"
