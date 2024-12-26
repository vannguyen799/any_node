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


expect -c "
spawn $last_line
set timeout 180

expect {
    -re \"(?i).*Enter wallet address.*\" {
        send \"$wallet_address\r\"
    }
    timeout {
        puts \"Timeout waiting for wallet address prompt\"
        exit 1
    }
}

expect {
    -re \"(?i).*Select drive you want to use.*\" {
        send \"\r\"
    }
    timeout {
        puts \"Timeout waiting for drive selection prompt\"
        exit 1
    }
}

expect {
    -re \"(?i).*Enter Disk size.*\" {

        send \"$storage_value\r\"
    }
    timeout {
        puts \"Timeout waiting for storage value prompt\"
        exit 1
    }
}

expect eof
"

