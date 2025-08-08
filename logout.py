import os
import subprocess
import requests

import warnings
warnings.filterwarnings("ignore")

def is_root():
    return os.geteuid() == 0

def get_connected_wifi():
    try:
        result = subprocess.check_output(["nmcli", "-t", "-f", "active,ssid", "dev", "wifi"]).decode()
        for line in result.splitlines():
            active, ssid = line.split(":")
            if active == "yes":
                return ssid
    except Exception:
        return None
    return None

def do_logout(username):
    if not is_root():
        print("ERROR: Script must be run as root.")
        return 1

    wifi = get_connected_wifi()
    if wifi != "DA_Public":
        print("ERROR: Not connected to DA_Public Wi-Fi.")
        return 1

    url = "https://dafirewall.daiict.ac.in:8090/httpclient.html"
    payload = {
        "mode": "193",
        "username": username,
        "a": "1663147780495",
        "producttype": "0"
    }

    try:
        response = requests.post(url, data=payload, verify=False)
        if response.status_code == 200:
            print("Logout successful.")
            return 0
        else:
            print("Logout failed. Already logged out or session expired.")
            return 1
    except Exception as e:
        print(f"Logout error: {e}")
        return 1