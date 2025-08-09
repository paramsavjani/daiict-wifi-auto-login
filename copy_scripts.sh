#!/bin/bash
set -e

cp login.py /usr/local/bin/
cp logout.py /usr/local/bin/
chmod +x /usr/local/bin/login.py /usr/local/bin/logout.py
echo "📂 Scripts copied to /usr/local/bin"