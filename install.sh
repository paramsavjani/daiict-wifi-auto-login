#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (use sudo)"
  exit 1
fi

echo "n" | bash uninstall.sh &> /dev/null
bash credentials_setup.sh
bash copy_scripts.sh
bash create_wrappers.sh
bash setup_services.sh

cat <<'EOF' > /usr/local/bin/wifi-keepalive.py
#!/usr/bin/env python3
import requests
import time
import warnings
warnings.filterwarnings("ignore")

BASE_URL = "https://dafirewall.daiict.ac.in:8090/live?mode=192&username={}&a={}&producttype=0"

with open("/etc/wifi-auth/credentials.txt") as f:
    username, password = [line.strip() for line in f.readlines()]

while True:
    ts = int(time.time() * 1000)
    url = BASE_URL.format(username, ts)
    try:
        requests.get(url, timeout=10, verify=False)
    except Exception as e:
        pass
    time.sleep(120)

EOF

chmod +x /usr/local/bin/wifi-keepalive.py

cat <<EOF > /etc/systemd/system/wifi-keepalive.service
[Unit]
Description=College WiFi KeepAlive
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/wifi-keepalive.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable wifi-keepalive.service >/dev/null 2>&1
systemctl start wifi-keepalive.service >/dev/null 2>&1

DESKTOP_FILE="/home/$SUDO_USER/Desktop/WiFi-Login.desktop"

cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Type=Application
Name=WiFi Login
Comment=Run wifi-login
Exec=/usr/local/bin/wifi-login >/dev/null 2>&1 &
Icon=network-wireless
Terminal=false
Categories=Utility;
EOF

chmod +x "$DESKTOP_FILE"
chown $SUDO_USER:$SUDO_USER "$DESKTOP_FILE"


DESKTOP_FILE="/home/$SUDO_USER/Desktop/WiFi-Logout.desktop"

cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Type=Application
Name=WiFi Login
Comment=Run wifi-logout
Exec=/usr/local/bin/wifi-logout >/dev/null 2>&1 &
Icon=network-wireless
Terminal=false
Categories=Utility;
EOF

chmod +x "$DESKTOP_FILE"
chown $SUDO_USER:$SUDO_USER "$DESKTOP_FILE"

echo "✅ Setup complete!"
echo "🔄 Running initial login..."
/usr/local/bin/wifi-login