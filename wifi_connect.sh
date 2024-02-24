#!/bin/bash

# Set network interface name (replace with your actual interface)
INTERFACE="wlan0"

# Configure known Wi-Fi networks (replace with your SSIDs and passwords)
KNOWN_NETWORKS=(
    "SSID1:PASSWORD1"
    "SSID2:PASSWORD2"
)

# Check for internet connection
ping -c 1 8.8.8.8 > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "Internet connection detected, exiting..."
    exit 0
fi

# Try connecting to known Wi-Fi networks
for network in "${KNOWN_NETWORKS[@]}"; do
    ssid="${network%%:}"
    password="${network##*:}"

    echo "Trying to connect to '$ssid'..."
    sudo wpa_supplicant -B -i $INTERFACE -c /etc/wpa_supplicant/$INTERFACE.conf &
    sleep 5

    if [[ $(iwconfig $INTERFACE | grep ESSID | awk '{print $4}') == "$ssid" ]]; then
        echo "Connected to '$ssid'"
        exit 0
    fi

    sudo killall wpa_supplicant
done

# No known network found, start hotspot
echo "No known network found, starting hotspot..."
sudo systemctl start hostapd
sudo systemctl start dnsmasq

# Wait for user connection (replace with your preferred method)
echo "Waiting for user to connect to hotspot..."
# Option 1: Using a web server (refer to AutoHotspot documentation)
# Option 2: Implementing a simple user interaction loop

# Get SSID and password from user
read -p "Enter SSID: " user_ssid
read -p "Enter password: " user_password

# Attempt to connect to user-provided network
echo "Trying to connect to '$user_ssid'..."
sudo wpa_supplicant -B -i $INTERFACE -c /etc/wpa_supplicant/$INTERFACE.conf &
sleep 5

if [[ $(iwconfig $INTERFACE | grep ESSID | awk '{print $4}') == "$user_ssid" ]]; then
    echo "Connected to '$user_ssid'"

    # Save user-provided credentials (optional)
    # echo "user_ssid:$user_ssid" | sudo tee -a /etc/wpa_supplicant/$INTERFACE.conf
    # echo "psk='$user_password'" | sudo tee -a /etc/wpa_supplicant/$INTERFACE.conf

    # Stop hotspot and enable networking
    sudo systemctl stop hostapd
    sudo systemctl stop dnsmasq
    sudo systemctl start networking

    exit 0
else
    echo "Failed to connect to '$user_ssid'"
    # Handle connection failure (e.g., retry, notify user)
fi

# If all attempts fail, restart the script on next boot (optional)
# sudo systemctl restart wifi_connect.sh
