#!/bin/bash
# setup_hp_t150.sh - Fully automated install script with forced reinstall

set -e

export DEBIAN_FRONTEND=noninteractive  # Prevent interactive prompts

echo "Starting full system update and reinstall process..."
apt-get update && apt-get upgrade -y

#########################
# 1. Reinstall Lightweight Desktop Environment (XFCE)
#########################
echo "Reinstalling XFCE desktop environment..."
apt-get install --reinstall -y xfce4 xfce4-goodies lightdm

# Optionally, reinstall LXDE instead:
# apt-get install --reinstall -y lxde lightdm

#########################
# 2. Reinstall Retro Gaming Software
#########################
echo "Reinstalling RetroArch and emulator dependencies..."
apt-get install --reinstall -y retroarch retroarch-assets

#########################
# 3. Reinstall MagicMirror²
#########################
echo "Reinstalling MagicMirror²..."
rm -rf ~/MagicMirror  # Remove old version
git clone https://github.com/MichMich/MagicMirror ~/MagicMirror
cd ~/MagicMirror
npm install --only=prod --force  # Force reinstall dependencies
cd ~

# Restart MagicMirror service if it exists
systemctl stop magicmirror.service || true
systemctl daemon-reload
systemctl enable magicmirror.service
systemctl start magicmirror.service

#########################
# 4. Reinstall Music & Voice Control
#########################
echo "Reinstalling MPD and ncmpcpp..."
apt-get install --reinstall -y mpd ncmpcpp

echo "Reinstalling Mycroft..."
pip3 install --upgrade --force-reinstall mycroft-core

# Restart Mycroft
mycroft-stop || true
mycroft-start debug &

#########################
# 5. Reinstall Graphics Drivers & Firmware
#########################
echo "Reinstalling graphics drivers..."
apt-get install --reinstall -y mesa-utils mesa-utils-extra firmware-linux

#########################
# 6. Reinstall WiFi & Networking Tools
#########################
echo "Reinstalling Network Manager..."
apt-get install --reinstall -y network-manager

# Restart Network Manager
systemctl restart NetworkManager

#########################
# 7. Reinstall Remote Access Tools (SSH & VNC)
#########################
echo "Reinstalling OpenSSH server..."
apt-get install --reinstall -y openssh-server
systemctl restart ssh

echo "Reinstalling VNC server..."
apt-get install --reinstall -y tightvncserver
mkdir -p ~/.vnc
cat << 'EOF' > ~/.vnc/xstartup
#!/bin/sh
xrdb $HOME/.Xresources
startxfce4 &
EOF
chmod +x ~/.vnc/xstartup

echo "Setup complete. Rebooting now..."
reboot
