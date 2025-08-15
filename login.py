import os
import subprocess
import requests
import warnings
import xml.etree.ElementTree as ET

warnings.filterwarnings("ignore")


def is_root():
    return os.geteuid() == 0


def get_connected_wifi():
    try:
        result = subprocess.check_output(
            ["nmcli", "-t", "-f", "active,ssid", "dev", "wifi"]
        ).decode()
        for line in result.splitlines():
            active, ssid = line.split(":")
            if active == "yes":
                return ssid
    except Exception:
        return None
    return None


def parse_message(xml_data, username):
    """Extract the <message> text from the XML response and replace {username}."""
    try:
        root = ET.fromstring(xml_data)
        message = root.find("message").text
        if message:
            return message.replace("{username}", username).strip()
        else:
            return "No message in response."
    except Exception:
        return "Invalid response format."


def do_login(username, password):
    if not is_root():
        print("ERROR: Script must be run as root.")
        return 1

    wifi = get_connected_wifi()
    if wifi != "DA_Public":
        print("ERROR: Not connected to DA_Public Wi-Fi.")
        return 1

    url = "https://dafirewall.daiict.ac.in:8090/httpclient.html"
    payload = {
        "mode": "191",
        "username": username,
        "password": password,
        "a": "1663147780495",
        "producttype": "0",
    }

    try:
        response = requests.post(url, data=payload, verify=False)
        if response.status_code == 200:
            message = parse_message(response.text,username)
            print(message)
            return 0 if "signed in" in message.lower() else 1
        else:
            print(f"HTTP Error: {response.status_code}")
            return 1
    except Exception as e:
        print(f"Login error: {e}")
        return 1