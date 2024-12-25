import argparse
import subprocess
import time

parser = argparse.ArgumentParser(description="")


parser.add_argument(*["--wallet_address", "-w"], help="Wallet address", default=None)
parser.add_argument(*["--storage_value", "-s"], help="Storage value", default=None)
args = parser.parse_args()


print(args.wallet_address, args.storage_value)

screen_name = "rival-" + str(int(time.time()))
subprocess.run(f"screen -S {screen_name}", shell=True, check=True)

output = subprocess.run(
    "n | ./rivalzDockerWithProxy.sh",
    shell=True,
    check=True,
    capture_output=True,
    text=True,
)

docker_cmd = output.stdout.split("\n")[-1]
if not docker_cmd.startswith("docker run -it --name"):
    raise Exception("docker_cmd: " + docker_cmd)

subprocess.run(
    f"printf {args.wallet_address}\\n{args.storage_value} | {docker_cmd}",
    shell=True,
    check=True,
)
