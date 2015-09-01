#!/bin/bash  
export MY_IP=$(hostname -i)
export LD_LIBRARY_PATH=/lib64:/lib
set -x

cat << EOF > /mesos-cloud.conf
[mesos-cloud]
  mesos-master        = zk://${ZK_IP}:${ZK_PORT}/mesos 
  http-client-timeout = 5s
  state-cache-ttl     = 20s
EOF

/bin/km apiserver \
    --address=${MY_IP} \
    --etcd-servers=http://${ETCD_IP}:${ETCD_PORT} \
    --service-cluster-ip-range=10.10.10.0/24 \
    --port=8888 \
    --cloud-provider=mesos \
    --cloud-config=/mesos-cloud.conf \
    --v=5 > /var/log/apiserver.log 2>&1 &
echo apiserver exit code $?

sleep 5

/bin/km controller-manager \
    --master=${MY_IP}:8888 \
    --cloud-provider=mesos \
    --cloud-config=/mesos-cloud.conf  \
    --v=1 > /var/log/controller.log 2>&1 &
echo controller exit code $?

sleep 5

/bin/km scheduler \
    --address=0.0.0.0 \
    --mesos-master=${MESOS_IP}:${MESOS_PORT} \
    --etcd-servers=http://${ETCD_IP}:${ETCD_PORT} \
    --mesos-user=root \
    --api-servers=${MY_IP}:8888 \
    --cluster-dns=10.10.10.10 \
    --cluster-domain=cluster.local \
    --v=2 > /var/log/scheduler.log 2>&1 
echo scheduler exit code $?

sleep 5

ps -ef |grep km
