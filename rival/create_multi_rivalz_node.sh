#!/bin/bash

echo 'wallet_address:'
read wallet_address
echo 'storage_value:'
read storage_value
echo 'node_number:'
read node_number

if [ ! -f "create_rivalz_node.sh" ]; then
  curl -O https://raw.githubusercontent.com/vannguyen799/any_node/refs/heads/master/rival/create_rivalz_node.sh
  chmod +x create_rivalz_node.sh
fi

for i in $(seq 1 $node_number); do
  name="rival-$(date +%s)"

  screen -dmS "$name" bash -c "echo -e '$wallet_address\n$storage_value' | ./create_rivalz_node.sh"
done
