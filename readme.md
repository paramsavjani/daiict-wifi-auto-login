# 📡 DA_Public Wi-Fi Auto Login & Logout  

**Automated login & logout for DA-IICT’s `DA_Public` Wi-Fi** using Python + systemd.  

![License](https://img.shields.io/badge/License-MIT-blue.svg)  
![OS](https://img.shields.io/badge/OS-Linux-green.svg)  
![Python](https://img.shields.io/badge/Python-3.x-yellow.svg)  

---

## ✨ Features

- 🔑 **Secure credential storage** — your username & password are stored with root-only permissions.  
- ⚡ **Automatic login** when connected to `DA_Public`.  
- 🔒 **Automatic logout** during shutdown/reboot.  
- 🛠 **Simple one-command installation**.  
- 📶 Works silently in the background using **systemd services**.  

---

## 📋 Requirements

- Linux (tested on **Ubuntu**, **Pop!_OS**, and **Arch Linux**).  
- Python 3 installed.  
- `nmcli` (comes with NetworkManager).  
- `requests` Python package.

**Install `requests`:**  

For **Arch Linux**:  

```bash
sudo pacman -S python-requests
```

For **Debian/Ubuntu**:  

```bash
sudo apt update
sudo apt install python3-pip -y
pip3 install requests
```

---

## 🚀 Installation

Clone the repository:

```bash
git clone https://github.com/paramsavjani/daiict-wifi-auto-login.git
cd daiict-wifi-auto-login
```

Run the setup:

```bash
sudo bash install.sh
```

During setup:  

- Enter your **Wi-Fi username & password**.  
- Scripts & services will be installed.  
- Ensure `DA_Public` is set to **auto-connect** in your system Wi-Fi settings.

---

## 🛠 How It Works

| File / Service            | Purpose |
|---------------------------|---------|
| `login.py`               | Logs into DA_Public on connect |
| `logout.py`              | Logs out before shutdown/reboot |
| `wifi-login.service`     | Runs login script after network connection |
| `wifi-logout.service`    | Runs logout script before shutdown |
| `/etc/wifi-auth/credentials.txt` | Stores encrypted credentials (root-only access) |

---

## ▶️ Usage

Manually log in:

```bash
sudo wifi-login
```

Manually log out:

```bash
sudo wifi-logout
```

---

## ⚠️ Security Notes

- Credentials are stored in `/etc/wifi-auth/credentials.txt` with `chmod 600`.  
- Connection uses HTTPS, but SSL verification is disabled due to DA_Public’s **self-signed certificate**.  

---

## 📜 License

Licensed under the [MIT License](LICENSE).  
Use at your own risk.

---

## 🙌 Contributions

You can help by:  

- Improving login/logout scripts.  
- Adding cross-platform support.  
- Enhancing security & speed.

Pull requests welcome! 🚀