#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (use sudo)"
  exit 1
fi

read -p "Enter your college WiFi username: " USERNAME
read -s -p "Enter your password: " PASSWORD
echo

mkdir -p /etc/wifi-auth
echo -e "$USERNAME\n$PASSWORD" > /etc/wifi-auth/credentials.txt
chmod 600 /etc/wifi-auth/credentials.txt

cp login.py /usr/local/bin/
cp logout.py /usr/local/bin/
chmod +x /usr/local/bin/login.py /usr/local/bin/logout.py

cat <<EOF > /usr/local/bin/wifi-login
from login import do_login
import sys
with open("/etc/wifi-auth/credentials.txt") as f:
    username, password = [line.strip() for line in f.readlines()]
sys.exit(do_login(username, password))
EOF

cat <<EOF > /usr/local/bin/wifi-logout
from logout import do_logout
import sys
with open("/etc/wifi-auth/credentials.txt") as f:
    username, password = [line.strip() for line in f.readlines()]
sys.exit(do_logout(username))
EOF

chmod +x /usr/local/bin/wifi-login /usr/local/bin/wifi-logout

cat <<EOF > /etc/systemd/system/wifi-login.service
[Unit]
Description=College WiFi Auto Login
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/wifi-login

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/wifi-logout.service
[Unit]
Description=College WiFi Auto Logout
DefaultDependencies=no
Before=shutdown.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/wifi-logout
RemainAfterExit=true

[Install]
WantedBy=halt.target poweroff.target reboot.target shutdown.target
EOF

systemctl daemon-reload
systemctl enable wifi-login.service
systemctl enable wifi-logout.service

echo "✅ Setup complete!"
echo "Please restart your system to apply the changes. Ensure that 'DA_Public' is set to auto-connect in your Wi-Fi settings."
