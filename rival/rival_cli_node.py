import asyncio
import os
import platform
from concurrent.futures.thread import ThreadPoolExecutor
from datetime import datetime

if platform.system() != 'Linux':
    raise Exception('Only Linux is supported')
del platform

import subprocess
import pexpect


w = input('Wallet address: ')
n = input('number node set up: ')
s = input('storage value: ')

if not os.path.exists('rivalzDockerWithProxy.sh'):
    subprocess.run(['curl'+'-O'+
                    'https://gist.githubusercontent.com/NodeFarmer/00b40ca4594ee340ab613eb625ce8db2/raw/rivalzDockerWithProxy.sh'])
    subprocess.run(['chmod', '+x', 'rivalzDockerWithProxy.sh'])

def new_screen(session_name = None):
    session_name = session_name or 'rival-'   + datetime.now().strftime('%Y%m%d%H%M%S')

    subprocess.run(['screen', '-dmS', session_name])
    return session_name

def rivalzDockerWithProxy_wrapped(session_name):
    command = f"screen -dmS {session_name} bash -c './rivalzDockerWithProxy.sh'" if session_name else'./rivalzDockerWithProxy.sh'
    child = pexpect.spawn(command)
    child.expect('Do you want to use a proxy? (Y/N):')
    child.sendline('N')
    child.expect(pexpect.EOF)
    output = child.before.decode("utf-8")
    cmd = output.strip().split('\n')[-1]
    if not cmd.startswith('docker run -it --name'):
        raise Exception('failed to run rivalzDockerWithProxy.sh got last line:\n' + cmd)
    return cmd

def save_log(*args):
    with open('rival__log.txt', 'a') as f:
        f.write('\n'.join([str(a) for a in args]) + '\n')
def setup_node(wallet_address, storage_value):
    session_name= new_screen()
    cmd = rivalzDockerWithProxy_wrapped(session_name)
    cmd = f"screen -dmS {session_name} bash -c '{cmd}'"
    child = pexpect.spawn(cmd)
    child.expect('? Enter wallet address (EVM):')
    child.sendline(wallet_address)
    child.expect('? Select drive you want to use:  (Use arrow keys)')
    child.sendline('\n')
    child.expect(r"\? Enter Disk size of overlay")
    child.sendline(storage_value)

    save_log(session_name,wallet_address)


async def main():
    wallet_address = w
    storage_value = int(s)
    node_number = int(n)

    with ThreadPoolExecutor(max_workers=10) as executor:
        tasks = [executor.submit(setup_node, wallet_address, storage_value) for _ in range(node_number)]
        await asyncio.gather(*tasks)




