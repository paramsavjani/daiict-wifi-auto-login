# 📡 DA_Public Wi-Fi Auto Login & Logout

This project automates **login** and **logout** for the `DA_Public` Wi-Fi network at DA-IICT.  
It uses `systemd` services to detect your connection and handle authentication automatically.

## ✨ Features

- 🔑 Securely stores your Wi-Fi credentials
- ⚡ Automatically logs in when connected to `DA_Public`
- 🔒 Automatically logs out when shutting down or restarting
- 🛠 Easy installation with one command

---

## 📋 Requirements

- Linux system (tested on Ubuntu/Pop!_OS)
- Python 3 installed
- `nmcli` installed (comes with NetworkManager)
- `requests` Python package

Install `requests` if needed:
If you are using **Arch Linux** or a derivative, install `requests` with:

```bash
sudo pacman -S python-requests
```

otherwise,

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

Run the setup script:

```bash
sudo ./install.sh
```

During setup:

- You will be asked to **enter your college Wi-Fi username and password**.
- Scripts and services will be installed.
- `DA_Public` should be set to **auto-connect** in your system Wi-Fi settings.

---

## 🛠 How It Works

1. **`login.py`** — Logs in to `DA_Public` when connected.
2. **`logout.py`** — Logs out from `DA_Public` before shutdown/reboot.
3. **`wifi-login.service`** — Runs login script after network connection.
4. **`wifi-logout.service`** — Runs logout script before shutdown.
5. Credentials are stored in `/etc/wifi-auth/credentials.txt` (root-only access).

---

## ▶️ Usage

Manually trigger login:

```bash
sudo wifi-login
```

Manually trigger logout:

```bash
sudo wifi-logout
```
---

## ⚠️ Security Notes

- Your credentials are stored in `/etc/wifi-auth/credentials.txt` with `chmod 600` (accessible only by root).
- The connection uses HTTPS, but SSL verification is disabled due to DA_Public's self-signed certificate.

---

## 📜 License

This project is open source under the MIT License.  
Feel free to modify and share — but use at your own risk.

---

## 🙌 Contributions

Pull requests are welcome!  
You can help by:

- Improving the login/logout scripts
- Making cross-platform installers