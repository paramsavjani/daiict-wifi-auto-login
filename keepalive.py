#!/usr/bin/env python3
"""Periodically re-run the same login as wifi-login to keep the session alive."""
import time
import warnings

warnings.filterwarnings("ignore")

from login import do_login

# Same POST as manual login; interval tuned for short college session timeouts.
KEEPALIVE_INTERVAL_SEC = 25

with open("/etc/wifi-auth/credentials.txt") as f:
    username, password = [line.strip() for line in f.readlines()]

while True:
    do_login(username, password, silent=True)
    time.sleep(KEEPALIVE_INTERVAL_SEC)
