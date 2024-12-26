import os
import subprocess
import time

import pandas as pd


def is_session_active(screen_name):
    try:
        # Run the 'screen -ls' command
        result = subprocess.run(
            ["screen", "-ls"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        if result.returncode != 0:
            raise Exception(result.stderr)

        output = result.stdout
        if f".{screen_name}       " in output:
            return True
        else:
            return False
    except FileNotFoundError:
        raise Exception("screen command not found")


if __name__ == "__main__":
    if "create_rivalz_node_screen.sh" not in os.listdir():
        subprocess.run(
            "curl -O https://raw.githubusercontent.com/vannguyen799/any_node/refs/heads/master/rival/create_rivalz_node_screen.sh "
            "&& chmod +x create_rivalz_node_screen.sh",
            shell=True,
            check=True,
        )
    if "create_rivalz_node.sh" not in os.listdir():
        subprocess.run(
            "curl -O https://raw.githubusercontent.com/vannguyen799/any_node/refs/heads/master/rival/create_rivalz_node.sh "
            "&& chmod +x create_rivalz_node.sh",
            shell=True,
            check=True,
        )

    subprocess.run("screen -wipe", check=True, shell=True)

    data = pd.read_csv(".data.csv").to_dict(orient="records")

    for row in data:
        screen_name = row["screen_name"]
        wallet_address = row["wallet_address"]
        storage_value = int(row["storage_value"])
        proxy_type = row["proxy_type"] or "http"
        proxy_ip = row["proxy_ip"]
        proxy_port = row["proxy_port"]
        proxy_username = row["proxy_username"]
        proxy_password = row["proxy_password"]

        if not is_session_active(screen_name):
            cmd = f"echo -e '{wallet_address}\n{storage_value}\n{proxy_type}\n{proxy_ip}\n{proxy_port}\n{proxy_username}\n{proxy_password}' | ./create_rivalz_node_screen.sh"
            subprocess.run(
                f"{cmd} | ./create_rivalz_node_screen.sh", shell=True, check=True
            )
        time.sleep(0.2)
