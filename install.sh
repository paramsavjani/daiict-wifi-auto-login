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
Name=WiFi Logout
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
