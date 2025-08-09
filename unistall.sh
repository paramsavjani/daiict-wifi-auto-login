#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (use sudo)"
  exit 1
fi

/usr/local/bin/wifi-logout
echo "🛑 Stopping and disabling services..."
systemctl stop wifi-login.service || true
systemctl stop wifi-logout.service || true
systemctl stop wifi-keepalive.service || true
systemctl disable wifi-login.service || true
systemctl disable wifi-logout.service || true
systemctl disable wifi-keepalive.service || true

echo "🗑 Removing service files..."
rm -f /etc/systemd/system/wifi-login.service
rm -f /etc/systemd/system/wifi-logout.service
rm -f /etc/systemd/system/wifi-keepalive.service

echo "🗑 Removing installed scripts..."
rm -f /usr/local/bin/wifi-login
rm -f /usr/local/bin/wifi-logout
rm -f /usr/local/bin/login.py
rm -f /usr/local/bin/logout.py
rm -f /usr/local/bin/wifi-keepalive.py

echo "🗑 Removing saved credentials..."
rm -rf /etc/wifi-auth

echo "🔄 Reloading systemd..."
systemctl daemon-reload

echo "✅ Uninstall complete! All services and files removed."
