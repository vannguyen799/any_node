import asyncio
import os
from concurrent.futures.thread import ThreadPoolExecutor
import time

import platform
from datetime import datetime

if platform.system() != "Linux":
    raise Exception("Only Linux is supported")
del platform

import subprocess
import pexpect


w = input("Wallet address: ")
n = input("number node set up: ")
s = input("storage value: ")

if not os.path.exists("rivalzDockerWithProxy.sh"):
    subprocess.run(
        [
            "curl"
            + "-O"
            + "https://gist.githubusercontent.com/NodeFarmer/00b40ca4594ee340ab613eb625ce8db2/raw/rivalzDockerWithProxy.sh"
        ]
    )
    subprocess.run(["chmod", "+x", "rivalzDockerWithProxy.sh"])


def new_screen(screen_name=None):
    screen_name = screen_name or f"rival-{datetime.now().timestamp()}"

    subprocess.run(["screen", "-dmS", screen_name])
    time.sleep(3)
    return screen_name


def screen_send_cmd(session_name, cmd):
    child = pexpect.spawn(f'screen -S {session_name} -X stuff "{cmd}\n"')
    print(child.command)
    return child


def rivalzDockerWithProxy_wrapped(screen_name):
    child = screen_send_cmd(screen_name, "./rivalzDockerWithProxy.sh")
    child.expect("Do you want to use a proxy? (Y/N):")
    child.sendline("N")
    child.expect(pexpect.EOF)
    output = child.before.decode("utf-8")
    cmd = output.strip().split("\n")[-1]
    if not cmd.startswith("docker run -it --name"):
        raise Exception("failed to run rivalzDockerWithProxy.sh got last line:\n" + cmd)
    return cmd


def close_screen(session_name):
    child = pexpect.spawn(f"screen -S {session_name} -X quit")
    child.wait()


def save_log(*args):
    with open("rival__log.txt", "a") as f:
        f.write("\n".join([str(a) for a in args]) + "\n")


def setup_node(wallet_address, storage_value):
    screen_name = new_screen()
    cmd = ""
    try:
        cmd = rivalzDockerWithProxy_wrapped(screen_name)
        child = screen_send_cmd(screen_name, cmd)
        child.expect("? Enter wallet address (EVM):")
        child.sendline(wallet_address)
        child.expect("? Select drive you want to use:  (Use arrow keys)")
        child.sendline("\n")
        child.expect(r"\? Enter Disk size of overlay")
        child.sendline(storage_value)

        save_log(screen_name, wallet_address)
        print(f"SUCCESS: {screen_name}")
    except Exception as e:
        print("ERROR: ", screen_name, e)
        close_screen(screen_name)

        raise e


async def main():
    wallet_address = w
    storage_value = int(s)
    node_number = int(n)

    with ThreadPoolExecutor(max_workers=10) as executor:
        loop = asyncio.get_running_loop()
        tasks = [
            loop.run_in_executor(executor, setup_node, wallet_address, storage_value)
            for _ in range(node_number)
        ]
        await asyncio.gather(*tasks)


if __name__ == "__main__":
    asyncio.run(main())
