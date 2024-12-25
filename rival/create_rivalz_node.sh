#!/usr/bin/env bash

echo 'wallet_address:'
read wallet_address
echo 'storage_value:'
read storage_value

last_line=$( echo -e "n" | ./rivalzDockerWithProxy.sh | tail -n 1)

if [[ "$last_line" != docker\ run\ -it\ --name* ]]; then
  echo "$last_line"
  exit 1
fi




#last_line="${last_line//-it/-i}"

echo "start $last_line"

#printf "$wallet_address\n\n$storage_value" | $last_line

#docker exec -it $last_line /bin/bash -c "echo -e \"$wallet_address\\n\\n$storage_value\" | $last_line"

# echo -e "0x811ef9e1e2B96b59a32E5A69E765eb96f341A3a0\n1\n300\n" | docker run -i --name rivalz-docker-18 rivalz-docker-18

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