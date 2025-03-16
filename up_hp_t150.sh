#!/bin/bash
# setup_hp_t150.sh - Fully automated install script without systemd

set -e
export DEBIAN_FRONTEND=noninteractive  # Prevent interactive prompts

echo "Starting full system update and reinstall process..."
sudo apt-get update && sudo apt-get upgrade -y

#########################
# 1. Reinstall Lightweight Desktop Environment (XFCE)
#########################
echo "Reinstalling XFCE desktop environment..."
sudo apt-get install --reinstall -y xfce4 xfce4-goodies lightdm

#########################
# 2. Reinstall Retro Gaming Software
#########################
echo "Reinstalling RetroArch and emulator dependencies..."
sudo apt-get install --reinstall -y retroarch retroarch-assets

#########################
# 3. Reinstall MagicMirror²
#########################
echo "Reinstalling MagicMirror²..."
rm -rf ~/MagicMirror  # Remove old version
git clone https://github.com/MichMich/MagicMirror ~/MagicMirror
cd ~/MagicMirror
npm install --only=prod --force  # Force reinstall dependencies
cd ~

# Start MagicMirror manually on boot using crontab
echo "Setting up MagicMirror to start on boot..."
(crontab -l ; echo "@reboot cd ~/MagicMirror && npm start") | crontab -

#########################
# 4. Reinstall Music & Voice Control
#########################
echo "Reinstalling MPD and ncmpcpp..."
sudo apt-get install --reinstall -y mpd ncmpcpp

echo "Reinstalling Mycroft..."
pip3 install --upgrade --force-reinstall mycroft-core

# Restart Mycroft
mycroft-stop || true
mycroft-start debug &

#########################
# 5. Reinstall Graphics Drivers & Firmware
#########################
echo "Reinstalling graphics drivers..."
sudo apt-get install --reinstall -y mesa-utils mesa-utils-extra firmware-linux

#########################
# 6. Reinstall WiFi & Networking Tools
#########################
echo "Reinstalling Network Manager..."
sudo apt-get install --reinstall -y network-manager

# Start Network Manager manually
sudo service network-manager start

#########################
# 7. Reinstall Remote Access Tools (SSH & VNC)
#########################
echo "Reinstalling OpenSSH server..."
sudo apt-get install --reinstall -y openssh-server

# Start SSH manually
sudo service ssh start

# Enable SSH on boot
sudo update-rc.d ssh enable

echo "Reinstalling VNC server..."
sudo apt-get install --reinstall -y tightvncserver

# Start VNC Server manually
vncserver :1

# Enable VNC on boot using crontab
echo "Setting up VNC to start on boot..."
(crontab -l ; echo "@reboot vncserver :1") | crontab -

echo "Setup complete. Rebooting now..."
sudo reboot
