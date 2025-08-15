import os
import subprocess
import requests
import warnings
import xml.etree.ElementTree as ET

warnings.filterwarnings("ignore")


def is_root():
    return os.geteuid() == 0


def notify_user(title, message):
    try:
        user = subprocess.check_output(["logname"], text=True).strip()
        dbus_addr = None
        found = False
        for pid in os.listdir("/proc"):
            if pid.isdigit():
                try:
                    with open(f"/proc/{pid}/environ", "rb") as f:
                        env = f.read().decode(errors="ignore")
                        if f"USER={user}" in env and "DBUS_SESSION_BUS_ADDRESS=" in env:
                            for part in env.split("\0"):
                                if part.startswith("DBUS_SESSION_BUS_ADDRESS="):
                                    dbus_addr = part.split("=", 1)[1]
                                    found = True
                                    break
                    if found:
                        break
                except (FileNotFoundError, ProcessLookupError, PermissionError):
                    continue

        if not dbus_addr:
            print("❌ Could not find DBus session for GUI user.")
            return

        subprocess.run(
            ["sudo", "-u", user, "env",
            f"DBUS_SESSION_BUS_ADDRESS={dbus_addr}",
            "DISPLAY=:0",
            "notify-send",
            "--icon=network-wireless",         
            title,
            message],
            check=False)
    
    except Exception as e:
        pass


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
    try:
        root = ET.fromstring(xml_data)
        message = root.find("message").text
        if message:
            return f"{message.replace('{username}', username).strip()}"

            
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
            notify_user("DAICT Wi-Fi Login", message)
        else:
            print(f"HTTP Error: {response.status_code}")
            return 1
    except Exception as e:
        print(f"Login error: {e}")
        return 1