# https://github.com/Mic92/python-mpd2 
import argparse
import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'lib', 'python-mpd2'))
import mpd

parser = argparse.ArgumentParser()
parser.add_argument('--host')
parser.add_argument('--port')
parser.add_argument('--cmd', action='append', nargs='+')
args = parser.parse_args()

client = mpd.MPDClient()
client.timeout = 5 # in seconds
client.idletimeout = None
client.connect(args.host, args.port)

def stringToNumber(str):
    try:
        return int(str)
    except ValueError:
        return str

for cmdArguments in args.cmd:
    method = cmdArguments[0]
    arguments = [stringToNumber(arg) for arg in cmdArguments]

    if method == "readpicture":
        # Just create the image file if possible with no special return value.
        try: 
            # Empty dictionary if picture isn't available.
            picture = client.readpicture(cmdArguments[1])
            if picture:
                file_path = cmdArguments[2]
                file = open(file_path, 'wb')
                file.write(picture['binary'])
                file.close()
        except:
            # Throws error if requested file doesn't exist.
            pass 
    else:
        method_to_run = getattr(client, method)
        result = method_to_run(*arguments[1:])
        if (result):
            sys.stdout.write(json.dumps(result))

client.close()
client.disconnect()            
