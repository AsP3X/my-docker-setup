#!/bin/bash

# container_name="openvpn"
# network_name="traefik-proxy"
# persistant_path="/etc/openvpn"
# hostname="$(hostname)"

# check if the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# check if a parameter is given
if [ -z "$1" ]; then
   echo "Usage: $0 <container name>"
   container_name="$1"
   exit 1
fi

# check if a second parameter is given
if [ -z "$2" ]; then
    echo "Usage: $0 <network name>"
    exit 1
fi

# check if a third parameter is given
if [ -z "$3" ]; then
   echo "Usage: $0 <persistant path>"
   exit 1
fi

# check if a fourth parameter is given
if [ -z "$4" ]; then
   echo "Usage: $0 <hostname>"
   exit 1
fi

container_name=$1
network_name=$2
persistant_path=$3
hostname=$4

echo ""
echo ""
echo $container_name
echo $network_name
echo $persistant_path
echo $hostname
echo ""
echo ""

# check if the persistant_path directory is not empty
if [ "$(ls -A $persistant_path)" ]; then
   rm -rf $persistant_path/*
fi

################################################################
#                      Validating variables                    #
################################################################

# check if the persistant_path directory exists
echo "Checking if the persistant path is a directory"
if [ ! -d "$persistant_path" ]; then
   echo "The persistant path is not a directory"
   exit 1
fi

# check if network_name is a docker network
echo "Checking if the network name is a docker network"
docker network inspect "$network_name" &> /dev/null
if [ $? -ne 0 ]; then
   echo "The network name is not a docker network"
   exit 1
fi

################################################################
#                                                              #
################################################################

# check if the container image "kylemanna/openvpn:latest" is available
echo "Checking if the container image is available"
docker image inspect kylemanna/openvpn:latest &> /dev/null
if [ $? -ne 0 ]; then
   docker pull kylemanna/openvpn:latest
fi

while [ $? -ne 0 ]; do
   echo "Waiting for the container image to be available"
   sleep 1
   docker image inspect kylemanna/openvpn:latest &> /dev/null
done


echo "Creating the configuration files"
docker run --name openvpn_confgenerate -v ${persistant_path}:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://${hostname}
sleep 4
while [ "$(docker inspect -f {{.State.Running}} openvpn_confgenerate)" == "true" ]; do
    sleep 1
done

# check if the file "openvpn.conf" is inside of persistant_path
echo "Checking if the configuration file is inside of the persistant path"
if [ ! -f "${persistant_path}/openvpn.conf" ]; then
   echo "ERROR: The file openvpn.conf is not inside of the persistant path"
   echo "Stopping the creation process"
   exit 1
fi

echo "Creating the server certificate"
docker run --name openvpn_initpki -v ${persistant_path}:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
sleep 4
while [ "$(docker inspect -f {{.State.Running}} openvpn_initpki)" == "true" ]; do
    sleep 1
done

# create a copy of "docker-compose.yml.copy" with the name "docker-compose.yml"
echo "Creating the docker-compose.yml file"

# create the "docker_compose_path" variable and remove /data from the persistant_path
docker_compose_path="${persistant_path%/data}"
cp ${docker_compose_path}/docker-compose.yml.copy ${docker_compose_path}/docker-compose.yml

sleep 1
# replace "REPLACE_WITH_CONTAINER_NAME" with the container_name in the docker-compose.yml file
echo "Replacing the container name in the docker-compose.yml file"
sed -i "s/REPLACE_WITH_CONTAINER_NAME/${container_name}/g" docker-compose.yml

sleep 1
# replace "REPLACE_WITH_NETWORK_NAME" with the network_name in the docker-compose.yml file
echo "Replacing the network name in the docker-compose.yml file"
sed -i "s/REPLACE_WITH_NETWORK_NAME/${network_name}/g" docker-compose.yml

sleep 1
# replace "/etc/openvpn_xxx" using the persistant_path in the docker-compose.yml file
echo "Replacing the persistant path in the docker-compose.yml file"
sed -i "s#REPLACE_WITH_PERSISTANT_PATH#${persistant_path}#g" docker-compose.yml


sleep 1
# run docker-compose up and wait for the line "Initialization Sequence Completed"
echo "Running docker-compose up"
docker-compose up -d
while [ "$(docker logs $container_name 2>&1 | grep "Initialization Sequence Completed")" == "" ]; do
    sleep 1
done

docker-compose down

# save the container name in a temporary file
touch ${persistant_path}/container_name
echo $container_name > ${persistant_path}/container_name

echo "Initialization Sequence Completed"
echo ""
echo "Stating clean up..."
sleep 1

# remove the container "openvpn_confgenerate" if it exists
echo "Removing the container openvpn_confgenerate"
docker rm openvpn_confgenerate &> /dev/null

# remove the container "openvpn_initpki" if it exists
echo "Removing the container openvpn_initpki"
docker rm openvpn_initpki &> /dev/null

# remove the container "$container_name" if it exists
echo "Removing the container $container_name"
docker rm $container_name &> /dev/null

sleep 2
echo "Clean up completed!"
echo ""
echo "You can now start the container with the command: docker-compose up -d"