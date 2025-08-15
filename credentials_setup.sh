#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (use sudo)"
  exit 1
fi

CRED_FILE="/etc/wifi-auth/credentials.txt"

if [ -f "$CRED_FILE" ]; then
  OLD_USERNAME=$(head -n 1 "$CRED_FILE")
  echo "✅ Credentials already exist."
  read -p "Do you want to use the existing credentials for $OLD_USERNAME? (y/N): " choice
  case "$choice" in
    [yY]|[yY][eE][sS])
      echo "🔒 Using existing credentials."
      ;;
    *)
      read -p "Enter your college WiFi username: " USERNAME
      read -s -p "Enter your password: " PASSWORD
      echo
      mkdir -p /etc/wifi-auth
      echo -e "$USERNAME\n$PASSWORD" > "$CRED_FILE"
      chmod 600 "$CRED_FILE"
      echo "🔑 Credentials updated."
      ;;
  esac
else
  read -p "Enter your college WiFi username: " USERNAME
  read -s -p "Enter your password: " PASSWORD
  echo
  mkdir -p /etc/wifi-auth
  echo -e "$USERNAME\n$PASSWORD" > "$CRED_FILE"
  chmod 600 "$CRED_FILE"
  echo "🔑 Credentials saved."
fi
