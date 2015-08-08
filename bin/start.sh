#!/bin/bash  
export MY_IP=$(hostname -i)
export MESOS_IP=${MESOS_IP}
export LD_LIBRARY_PATH=/lib64:/lib
set -x

/bin/km apiserver \
    --address=${MY_IP} \
    --etcd-servers=http://${MESOS_IP}:4001 \
    --service-cluster-ip-range=10.10.10.0/24 \
    --port=8888 \
    --cloud-provider=mesos \
    --cloud-config=/vagrant/mesos-cloud.conf \
    --v=5 > /var/log/apiserver.log 2>&1 &
echo apiserver exit code $?

sleep 5

/bin/km controller-manager \
    --master=${MY_IP}:8888 \
    --cloud-provider=mesos \
    --cloud-config=/vagrant/mesos-cloud.conf  \
    --v=1 > /var/log/controller.log 2>&1 &
echo controller exit code $?

sleep 5

/bin/km scheduler \
    --address=${MY_IP} \
    --mesos-master=${MESOS_IP}:5050 \
    --etcd-servers=http://${MESOS_IP}:4001 \
    --mesos-user=root \
    --api-servers=${MY_IP}:8888 \
    --cluster-dns=10.10.10.10 \
    --cluster-domain=cluster.local \
    --v=2 > /var/log/scheduler.log 2>&1 
echo scheduler exit code $?

sleep 5

ps -ef |grep km
