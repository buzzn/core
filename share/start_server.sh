#!/usr/bin/env bash
set -x
POSTGRES_SHA="sha512-87481d3cfd8da59d6076d46e35ed04b5"
REDIS_SHA="sha512-fa10aba0aa48d0a18a520bfcbb1dc5b7"
MYSQL_SHA="sha512-807b491e03a407982f5ba7f007de01e4"
[[ -z $(mount | grep /ramfs) ]] && sudo mount -t tmpfs -o size=2048M none /ramfs
sudo mkdir -p /ramfs/buzzn_core_dev /ramfs/buzzn_core_redis /ramfs/beekeeper
sudo rkt run $MYSQL_SHA --environment=MYSQL_ROOT_PASSWORD=secret --volume volume-var-lib-mysql,kind=host,source=/ramfs/beekeeper,readOnly=false &
sudo rkt run $REDIS_SHA --volume volume-data,kind=host,source=/ramfs/buzzn_core_redis,readOnly=false &
sudo rkt run $POSTGRES_SHA --volume volume-var-lib-postgresql-data,kind=host,source=/ramfs/buzzn_core_dev,readOnly=false &
