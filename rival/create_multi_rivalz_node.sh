#!/bin/bash
log_file="rivalz_node_create_log.csv"

if [ ! -f "$log_file" ]; then
    echo "timestamp,screen_name,wallet_address,storage_value" > "$log_file"
fi

echo 'wallet_address:'
read wallet_address
echo 'storage_value:'
read storage_value
echo 'How many node to create:'
read node_number


# curl -O https://raw.githubusercontent.com/vannguyen799/any_node/refs/heads/master/rival/create_multi_rivalz_node.sh && chmod +x create_multi_rivalz_node.sh && ./create_multi_rivalz_node.sh
curl -O https://raw.githubusercontent.com/vannguyen799/any_node/refs/heads/master/rival/create_rivalz_node.sh
chmod +x create_rivalz_node.sh

for i in $(seq 1 $node_number); do
  name="rival-$wallet_address-$(date +%s)-$i"
  echo "$i screen $name start"
  screen -dmS "$name" bash -c "echo -e '$wallet_address\n$storage_value' | ./create_rivalz_node.sh; sleep infinity"

  echo "$(date +%Y-%m-%dT%H:%M:%S),$name,$wallet_address,$storage_value" >> "$log_file"
  sleep 0.3
done


wait

echo "Done"