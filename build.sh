#!/bin/bash

KMNAME=km-build-$( date +"%s")
rm -f bin/km
rm -f lib64/*
mkdir -p lib64 usr var/log

docker run -d --name ${KMNAME} -e GIT_BRANCH=release-1.0 mesosphere/kubernetes-mesos-build:latest
docker attach ${KMNAME}
docker wait ${KMNAME}

# TODO get libs from build container not the host running this script
#docker cp ${KMNAME}:/target/km $(pwd)/bin/
#docker cp ${KMNAME}:/lib64/ld-linux-x86-64.so.2 $(pwd)/lib64/
#docker cp ${KMNAME}:/lib64/libc.so.6 $(pwd)/lib64/
#docker cp ${KMNAME}:/lib64/libdl.so.2 $(pwd)/lib64/
#docker cp ${KMNAME}:/lib64/libpthread.so.0 $(pwd)/lib64/libpthread.so.0

cp /lib64/ld-linux-x86-64.so.2 $(pwd)/lib64/
cp /lib64/libc.so.6 $(pwd)/lib64/
cp /lib64/libdl.so.2 $(pwd)/lib64/
cp /lib64/libpthread.so.0 $(pwd)/lib64/

docker rm ${KMNAME}

KMVERSION=$(./bin/km --version| sed 's/Kubernetes v//'| cut -d'+' -f1)

docker build -t ddoc/kubernetes-mesos:${KMVERSION} .
docker push docker.io/ddoc/kubernetes-mesos:${KMVERSION}
