#!/bin/bash
set -e

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
echo "🛠️ Services created and enabled."