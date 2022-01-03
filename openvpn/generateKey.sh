#!/bin/bash

# check if the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# check if a parameter is given
if [ -z "$1" ]; then
   echo "Usage: $0 <persistant_path>"
   exit 1
fi

persistant_path=$1
# create keys_path and replace /data with /keys
keys_path=$(echo $persistant_path | sed 's/data/keys/g')

# check if the keys directory exists
if [ ! -d "$persistant_path/keys" ]; then
   mkdir $keys_path
fi

read -p "username: " cvpn_username
read -p "password: " cvpn_password

###############################################################
#                    Checking for Service                     #
###############################################################
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# cat the container_name from the "container_name"
container_name_path=${persistant_path}/container_name
container_name=$(cat $container_name_path)

# check if the docker container with the name "container_name" is running
if [ "$(docker inspect -f {{.State.Running}} $container_name)" != "true" ]; then
   echo "The container $container_name is not running"
   exit 1
fi

###############################################################
#                      Generating keys                        #
###############################################################
# create a variable with the path to the persistant_path and replace /data with /keys
cd ${persistant_path}

# check if a password is given and if not, ask for one
if [ -z "$cvpn_password" ]; then
  docker run -v ${persistant_path}:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full ${cvpn_username} nopass
else
  docker run -v ${persistant_path}:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full ${cvpn_username} ${cvpn_password}
fi

docker run -v ${persistant_path}:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient ${cvpn_username} > ${keys_path}/${cvpn_username}.ovpn

echo "The client ${cvpn_username} has been generated"
echo "You can find the client in ${keys_path}/${cvpn_username}.ovpn"