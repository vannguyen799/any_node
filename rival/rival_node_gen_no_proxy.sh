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
flag_f="rival_node_with_proxy_wrapped_flag.log"

check_file_exists() {
  cd $HOME

  # Method 1: Using -f (test operator)
  if [[ -f "$flag_f" ]]; then
    return 0
  fi

  # Method 2: Using test command (same as -f but different style)
  if test -f "$flag_f"; then
    return 0
  fi

  # Method 3: Using ls command
  if ls "$flag_f" &>/dev/null; then
    return 0
  fi

  # Method 4: Using stat command
  if stat "$flag_f" &>/dev/null; then
    return 0
  fi

  # If none of the checks succeed, return 1
  return 1
}


for i in $(seq 1 $node_number); do
  rm $flag_f

  screen_name="rival_node_$i$(date +%s)"
  echo "Node $i screen $screen_name start"

  cmd="echo -e \"n\n$wallet_address\n$storage_value\n$flag_f\" | ./rival_node_with_proxy_wrapped.sh; sleep infinity"

  screen -dmS "$screen_name" bash -c "$cmd"
  while ! check_file_exists; do
  echo -n '.'
  ls
  sleep 2
done
  echo "Done"
  sleep 5
done



rm -f rival_node_with_proxy_wrapped.sh