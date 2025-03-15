#!/bin/bash

echo "🚀 Fixing VIA VX900 GPU Issues on antiX Linux..."

# 1️⃣ Check if GPU is detected
echo "🔍 Checking GPU..."
lspci | grep -i vga
ls /dev/dri

# 2️⃣ Install OpenChrome Driver
echo "📦 Installing OpenChrome Driver..."
sudo apt update
sudo apt install --reinstall xserver-xorg-video-openchrome -y

# 3️⃣ Create Xorg Configuration File
echo "📝 Configuring Xorg..."
sudo tee /etc/X11/xorg.conf > /dev/null <<EOF
Section "Device"
    Identifier "VIA Graphics"
    Driver "openchrome"
EndSection
EOF

# 4️⃣ Load VIA DRM Modules
echo "📌 Loading VIA DRM modules..."
sudo modprobe via
sudo modprobe viafb
sudo modprobe drm

# 5️⃣ Check if /dev/dri/card0 is available
if [ ! -e /dev/dri/card0 ]; then
    echo "❌ No /dev/dri/card0 found. Trying fbdev fallback..."
    sudo tee /etc/X11/xorg.conf > /dev/null <<EOF
Section "Device"
    Identifier "VIA Graphics"
    Driver "fbdev"
EndSection
EOF
fi

# 6️⃣ Restart Xorg and Try startx
echo "🔄 Restarting Xorg..."
sudo service slim restart
startx

# 7️⃣ If still fails, downgrade to Kernel 4.19
echo "⚡ Checking for Kernel Downgrade..."
uname -r | grep "6."
if [ $? -eq 0 ]; then
    echo "🔻 Installing Kernel 4.19..."
    sudo apt install linux-image-4.19-amd64 -y
    echo "✅ Reboot and select Kernel 4.19 from GRUB menu."
fi

echo "🚀 Fix Complete! Try startx again."
