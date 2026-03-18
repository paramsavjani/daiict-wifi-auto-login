#!/bin/bash
set -e

cp login.py /usr/local/bin/
cp logout.py /usr/local/bin/
cp keepalive.py /usr/local/bin/wifi-keepalive.py
chmod +x /usr/local/bin/login.py /usr/local/bin/logout.py /usr/local/bin/wifi-keepalive.py