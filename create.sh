#!/bin/sh


REGEX='^node-[0-9]{1,}$'

for m in $(docker-machine ls -q); do 
    if [[ $m =~ $REGEX ]] 
    then 

        echo "${m} exists remove it? [y/n] "

        read response

        if [ "$(echo "$response" | tr '[:upper:]' '[:lower:]')" == "y" ] 
            then 
            docker-machine rm -y ${m}
        fi
    fi
done;


for i in 1 2 3; do
  docker-machine create --engine-insecure-registry namic:5000 -d virtualbox node-$i
done

./docker-machine-ipconfig.sh static node-1 192.168.99.113


eval $(docker-machine env node-1)

docker swarm init --advertise-addr $(docker-machine ip node-1)

TOKEN=$(docker swarm join-token -q worker)

for i in 2 3; do
  eval $(docker-machine env node-$i)
  docker swarm join --token $TOKEN $(docker-machine ip node-1):2377
done

echo "Swarm cluster has been successfuly created !";

eval $(docker-machine env node-1)

docker node ls
