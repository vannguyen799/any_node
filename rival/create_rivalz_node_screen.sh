echo "screen_name"
read screen_name
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

log_file="rivalz_node_create_log.csv"

if [ ! -f "$log_file" ]; then
    echo "timestamp,screen_name,wallet_address,storage_value" > "$log_file"
fi

screen -dmS "$screen_name" bash -c "echo -e '$wallet_address\n$storage_value\n$proxy_type\n$proxy_ip\n$proxy_port\n$proxy_username\n$proxy_password' | ./create_rivalz_node.sh; sleep infinity"

echo "$(date +%Y-%m-%dT%H:%M:%S),$screen_name,$wallet_address,$storage_value" >> "$log_file"


