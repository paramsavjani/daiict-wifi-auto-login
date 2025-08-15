#!/bin/bash
set -e

cat <<EOF > /usr/local/bin/wifi-login
#!/usr/bin/env python3
from login import do_login
import sys
with open("/etc/wifi-auth/credentials.txt") as f:
    username, password = [line.strip() for line in f.readlines()]
sys.exit(do_login(username, password))
EOF

cat <<EOF > /usr/local/bin/wifi-logout
#!/usr/bin/env python3
from logout import do_logout
import sys
with open("/etc/wifi-auth/credentials.txt") as f:
    username, password = [line.strip() for line in f.readlines()]
sys.exit(do_logout(username))
EOF

chmod +x /usr/local/bin/wifi-login /usr/local/bin/wifi-logout