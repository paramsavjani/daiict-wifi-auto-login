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

systemctl daemon-reload >/dev/null 2>&1
systemctl enable wifi-login.service >/dev/null 2>&1
systemctl enable wifi-logout.service >/dev/null 2>&1