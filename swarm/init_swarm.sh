#!/bin/bash

jq -r ".[] | .ansible_facts.managers" /root/manager_list > /root/managers
jq -r ".[] | .ansible_facts.workers" /root/worker_list > /root/workers

###########################
# get swarm manager token
###########################
docker-machine ssh leader_address > /root/swarm_manager_token 2>&1 << EOF
#docker-machine ssh docker-machine-manager-test-01 > /root/swarm_manager_token 2>&1 << EOF
  sudo su -
  docker swarm init --advertise-addr eth0
  sleep 3
  SMGR=$(docker swarm join-token manager | grep docker)
  echo $SMGR
  exit
  exit
EOF
TOKEN=$(grep "docker swarm join --token manager" /root/swarm_manager_token)

###########################
# get swarm worker token
###########################
docker-machine ssh leader_address > /root/swarm_worker_token 2>&1 << EOF
#docker-machine ssh docker-machine-manager-test-01 > /root/swarm_worker_token 2>&1 << EOF
  sudo su -
  SWKR=$(docker swarm join-token worker | grep docker)
  echo $SWKR
  exit
  exit
EOF
WTOKEN=$(grep "docker swarm join --token" /root/swarm_worker_token)

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

###########################
# clean up temp files
###########################
#rm -f /root/swarm_manager_cmd
#rm -f /root/manager_list