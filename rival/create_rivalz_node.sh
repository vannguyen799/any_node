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