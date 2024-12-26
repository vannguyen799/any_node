#!/usr/bin/env bash




echo 'wallet_address:'
read wallet_address
echo 'storage_value:'
read storage_value
echo 'proxy_type:'
read proxy_type
echo 'proxy_ip:'
read proxy_ip
echo 'proxy_port:'
read proxy_port
echo 'proxy_username:'
read proxy_username
echo 'proxy_password:'
read proxy_password






if [ ! -f "rivalzDockerWithProxy.sh" ]; then
  curl -O https://gist.githubusercontent.com/NodeFarmer/00b40ca4594ee340ab613eb625ce8db2/raw/rivalzDockerWithProxy.sh
  chmod +x rivalzDockerWithProxy.sh
fi

last_line=$( echo -e "y\n$proxy_type\n$proxy_ip\n$proxy_port\n$proxy_username\n$proxy_password" | ./rivalzDockerWithProxy.sh | tail -n 1)

if [[ "$last_line" != docker\ run\ -it\ --name* ]]; then
  echo "$last_line"
  exit 1
fi





echo "start $last_line"


ex

