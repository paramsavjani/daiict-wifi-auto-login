import os
import subprocess
import requests

import warnings
warnings.filterwarnings("ignore")

def get_gui_user():
    # Try loginctl first (systemd way, works better for services)
    # Format: SESSION UID USER SEAT TTY
    fallback_user = None
    try:
        out = subprocess.check_output(["loginctl", "list-sessions", "--no-legend"], text=True)
        for line in out.splitlines():
            parts = line.split()
            if len(parts) >= 3:
                session_id = parts[0]
                username = parts[2]  # Third column is the username
                if username and username != "root":
                    # Check if session is graphical (x11 or wayland)
                    try:
                        session_type = subprocess.check_output(
                            ["loginctl", "show-session", session_id, "-p", "Type", "--value"],
                            text=True, stderr=subprocess.DEVNULL
                        ).strip()
                        if session_type in ["x11", "wayland"]:
                            return username
                        # Keep first non-root user as fallback
                        if not fallback_user:
                            fallback_user = username
                    except Exception:
                        # If we can't check type, keep as fallback
                        if not fallback_user:
                            fallback_user = username
        # Return fallback user if we found one but couldn't verify session type
        if fallback_user:
            return fallback_user
    except Exception:
        pass
    
    # Fallback to 'who' command
    try:
        out = subprocess.check_output(["who"], text=True).splitlines()
        for line in out:
            parts = line.split()
            if parts and parts[0] != "root":
                return parts[0]
    except Exception:
        pass
    
    # Fallback: check for users with X11/Wayland display
    try:
        for user_dir in os.listdir("/home"):
            user_path = f"/home/{user_dir}"
            if os.path.isdir(user_path):
                # Check for .Xauthority or active display
                xauth = os.path.join(user_path, ".Xauthority")
                if os.path.exists(xauth):
                    return user_dir
    except Exception:
        pass
    
    return None

def notify_user(title, message):
    user = get_gui_user()
    if not user:
        print("❌ No GUI user found.")
        return

    dbus_addr = None
    for pid in os.listdir("/proc"):
        if pid.isdigit():
            try:
                with open(f"/proc/{pid}/environ", "rb") as f:
                    env = f.read().decode(errors="ignore")
                    if f"USER={user}" in env and "DBUS_SESSION_BUS_ADDRESS=" in env:
                        for part in env.split("\0"):
                            if part.startswith("DBUS_SESSION_BUS_ADDRESS="):
                                dbus_addr = part.split("=", 1)[1]
                                break
                if dbus_addr:
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
         "notify-send", "--urgency=normal", "--icon=network-wireless",
         title, message],
        check=False
    )

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
            notify_user("DAICT Wi-Fi Logout", "Logout successful.")
            return 0
        else:
            notify_user("DAICT Wi-Fi Logout", "Logout failed. Already logged out or session expired.")
            return 1
    except Exception as e:
        print(f"Logout error: {e}")
        return 1