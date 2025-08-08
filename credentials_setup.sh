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
echo "🔑 Credentials saved."