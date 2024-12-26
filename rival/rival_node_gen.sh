#!/bin/bash

is_session_active() {
    screen_name=$1
    if screen -ls | grep -q "\.${screen_name}"; then
        return 0 # session active
    else
        return 1 # session not active
    fi
}

if ! curl -O https://raw.githubusercontent.com/vannguyen799/any_node/refs/heads/master/rival/rival_node_with_proxy_wrapped.sh; then
    echo "Failed to download script.sh"
    exit 1
fi

chmod +x rival_node_with_proxy_wrapped.sh

mkdir -p ./tmp

screen -wipe

if [[ ! -f data.csv ]]; then
    echo "data.csv not found"
    exit 1
fi

while IFS=',' read -r wallet_address storage_value screen_name proxy_type proxy_ip proxy_port proxy_username proxy_password; do
    if [[ "$screen_name" != "screen_name" ]]; then
        proxy_type=${proxy_type:-"http"}
        storage_value=$(printf "%d" "$storage_value" 2>/dev/null)

        if ! is_session_active "$screen_name"; then
            fcheck="./tmp/$screen_name$(date +%s).log"
            cmd="echo -e \"y\n$proxy_type\n$proxy_ip\n$proxy_port\n$proxy_username\n$proxy_password\n$wallet_address\n$storage_value\" | ./script.sh; echo $screen_name > $fcheck; sleep infinity"

            echo "Processing: $screen_name - $wallet_address $storage_value $proxy_ip:$proxy_port:$proxy_username:$proxy_password"
            screen -dmS "$screen_name" bash -c "$cmd"
            if [[ $? -ne 0 ]]; then
                echo "Failed to execute command for $screen_name" >> error.log
                continue
            fi

            until [ -f "$fcheck" ]; do
                sleep 1
            done
            echo "Done"
        fi
    fi
    sleep 0.2
done < data.csv
