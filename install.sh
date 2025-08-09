#!/bin/bash
set -e

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
    time.sleep(60)

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

systemctl enable wifi-keepalive.service
systemctl start wifi-keepalive.service

echo "✅ Setup complete!"
echo "🔄 Running initial login..."
/usr/local/bin/wifi-login