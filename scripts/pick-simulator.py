import json
import re
import subprocess
import sys

runtimes = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "-j"]))["devices"]


def version(key):
    match = re.search(r"iOS-(\d+)-(\d+)", key)
    return (int(match.group(1)), int(match.group(2))) if match else (0, 0)


def rank(device):
    name = device["name"]
    return (("Pro" in name and "Max" not in name), "iPhone" in name, name)


for key in sorted(runtimes, key=version, reverse=True):
    phones = [d for d in runtimes[key] if d["name"].startswith("iPhone")]
    if phones:
        best = sorted(phones, key=rank, reverse=True)[0]
        print(best["udid"])
        sys.stderr.write("simulator %s on %s\n" % (best["name"], key))
        sys.exit(0)

sys.exit("no iPhone simulator available")
