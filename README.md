execute build.sh to build the container.

it is on docker hub here: https://hub.docker.com/r/ddoc/kubernetes-mesos

by default the container executes /bin/start.sh on boot

example for running the container:

  docker run -d --hostname $(uname -n) --name kubernetes-mesos \
    -v /vagrant:/var/log -v /vagrant/mesos-cloud.conf:/vagrant/mesos-cloud.conf \
    -e "MESOS_IP=${MASTER_IP}" \
    -p 8888:8888 ddoc/kubernetes-mesos:1.0.3.1 

