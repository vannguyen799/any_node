import asyncio
import os
from concurrent.futures.thread import ThreadPoolExecutor
import time

from datetime import datetime
import platform

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
    subprocess.run(
        ["screen", "-dmS", screen_name],
        check=True,
        capture_output=True,
        text=True,
        shell=True,
    )
    print('Create screen "' + screen_name + '", screen -r ' + screen_name)
    time.sleep(2)
    return screen_name


def screen_send_cmd(screen_name, cmd, log_txt_wait="", timeout=180):
    log = f"./tmp/{screen_name}.{datetime.now().timestamp()}.log"
    cmd = f'screen -S "{screen_name}" -X stuff "{cmd} > {log}\n"'
    try:
        subprocess.run(
            cmd,
            check=True,
            shell=True,
        )
        cur = time.time()
        while time.time() - cur < timeout:
            if os.path.exists(log):
                with open(log, "r") as f:
                    d = f.read()
                    if len(d) > 0:
                        if log_txt_wait in d:
                            return d
                        if log_txt_wait is None:
                            return d
            time.sleep(1)
        raise Exception("Timeout")
    except Exception as e:
        try:
            subprocess.run(["rm", log])
        except:
            pass
        raise e
    finally:
        try:
            subprocess.run(["rm", log])
        except:
            pass


def rivalzDockerWithProxy_wrapped(screen_name):
    d = screen_send_cmd(
        screen_name,
        "n | ./rivalzDockerWithProxy.sh",
        log_txt_wait="Setup is complete. To run the Docker container, use the following command:",
    )

    c = d.strip().split("\n")[-1]
    if not c.startswith("docker run -it --name"):
        raise Exception(c)
    return c


def close_screen(session_name):
    child = pexpect.spawn(f"screen -S {session_name} -X quit")
    child.wait()


def save_log(*args):
    with open("rival__log.txt", "a") as f:
        f.write("\n".join([str(a) for a in args]) + "\n")


def setup_node(wallet_address, storage_value):
    screen_name = new_screen()

    try:
        c = rivalzDockerWithProxy_wrapped(screen_name)
        screen_send_cmd(screen_name, f"printf {wallet_address}\\n{storage_value} | {c}")
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
