#!/bin/bash

# screen -ls | grep 'rival' | awk '{print $1}' | xargs -I{} screen -S {} -X quit && screen -ls

# curl -O https://raw.githubusercontent.com/vannguyen799/any_node/refs/heads/master/rival/rival_node_gen_no_proxy.sh &> /dev/null && chmod +x rival_node_gen_no_proxy.sh && ./rival_node_gen_no_proxy.sh


is_session_active() {
    screen_name=$1
    if screen -ls | grep -q "\.${screen_name}"; then
        return 0 # session active
    else
        return 1 # session not active
    fi
}

if ! curl -O https://raw.githubusercontent.com/vannguyen799/any_node/refs/heads/master/rival/rival_node_with_proxy_wrapped.sh &> /dev/null; then
    echo "Failed to download rival_node_with_proxy_wrapped.sh"
    exit 1
fi

chmod +x rival_node_with_proxy_wrapped.sh

mkdir -p ./tmp

screen -wipe &> /dev/null

read -p "Enter wallet_address " wallet_address
read -p "Enter storage_value " storage_value
read -p "Enter node number to create : " node_number

echo "Creating $node_number rival node(s) with no proxy..."

for i in $(seq 1 $node_number); do
  screen_name="rival_node_$i$(date +%s)"
  echo "Node $i screen $screen_name start"
  cmd="echo -e \"n\n$wallet_address\n$storage_value\" | ./rival_node_with_proxy_wrapped.sh; sleep infinity"

  flag_f="./tmp/rival_node_with_proxy_wrapped_flag.log"
  rm -f $flag_f

  screen -dmS "$screen_name" bash -c "$cmd"
  until [ -f "$flag_f" ]; do
    echo -n '.'
    sleep 2
  done
  echo "Done"
  sleep 5
done



rm -f rival_node_with_proxy_wrapped.sh