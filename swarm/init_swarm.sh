#!/bin/bash

jq -r ".[] | .ansible_facts.managers" /root/manager_list > /root/managers
jq -r ".[] | .ansible_facts.workers" /root/worker_list > /root/workers

###########################
# get swarm manager token
###########################
docker-machine ssh leader_address > /root/swarm_manager_token 2>&1 << EOF
  sudo su -
  docker swarm init --advertise-addr eth0
  docker swarm join-token manager | grep docker
  exit
  exit
EOF
TOKEN=$(grep "docker swarm join --token" /root/swarm_manager_token | tail -1)
echo MANAGER_TOKEN=$TOKEN
###########################
# get swarm worker token
###########################
docker-machine ssh leader_address > /root/swarm_worker_token 2>&1 << EOF
  sudo su -
  docker swarm join-token worker | grep docker
  exit
  exit
EOF
WTOKEN=$(grep "docker swarm join --token" /root/swarm_worker_token)
echo WORKER_TOKEN=$WTOKEN
###########################
# join docker-machine managers to swarm
###########################
while read m; do
docker-machine ssh $m > /root/manager-temp-results 2>&1 << EOF
  sudo su -
  echo running [$TOKEN]
  $TOKEN
  echo done running
  exit
  exit
EOF
done </root/managers

###########################
# join docker-machine workers to swarm
###########################
while read w; do
docker-machine ssh $w > /root/worker-temp-results 2>&1 << EOF
  sudo su -
  echo running [$WTOKEN]
  $WTOKEN
  echo done running
  exit
  exit
EOF
done </root/workers
