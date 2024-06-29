#!/bin/bash
#header----------------------------------------------------------------------------------------
# scriptname:            install-wg-confgen
# scriptversion:         1.0
# script description:    
# creator:               turukmoorea
# create datetime:       2024.06.29 20:19:39
# permissions:			   
#script----------------------------------------------------------------------------------------

# Checks which OS is installed.
if [ -f /etc/os-release ]; then
    . /etc/os-release
    varOsName=$NAME
else
    echo '-> An attempt was made to read the file "/etc/os-release". The file was not found.'
    exit 1001 # The OS could not be read out.
fi

# Checks whether WireGuard is installed.
case "$varOsName" in
    "Ubuntu" | "Debian")
        if ! dpkg -s wireguard &>/dev/null; then
            echo 'WireGuard is NOT installed on this device. Please install WireGuard. Try "apt-get install wireguard"'
            exit 1002 # WireGuard is NOT installed on this device.
        fi
        ;;
    "Alpine Linux")
        if ! apk info wireguard &>/dev/null; then
            echo 'WireGuard is NOT installed on this device. Please install WireGuard. Try "apk add wireguard-tools"'
            exit 1002 # WireGuard is NOT installed on this device.
        fi
        ;;
    *)
        echo "WireGuard installation: Operating system not recognized."
        exit 1001 # The OS could not be read out.
        ;;
esac

varWg_confgenLocation="/etc/wireguard/wg-confgen"
sudo mkdir -p "$varWg_confgenLocation"

# Check if wg-confgen directory is empty
if [ -z "$(sudo ls -A "$varWg_confgenLocation")" ]; then
    # Define temporary download directory
    temp_download_dir="/tmp/download/wireguard"
    sudo mkdir -p "$temp_download_dir"

    # Download wg-confgen from GitHub
    if ! sudo curl -L https://github.com/Turukmoorea/wg-confgen/archive/refs/heads/master.zip -o "/tmp/download/wireguard/wg-confgen.zip"; then
        echo "Failed to download wg-confgen."
        exit 1003 # zip-file could not be downloaded
    fi

    # Extract wg-confgen folder
    if ! sudo unzip -qn "$temp_download_dir/wg-confgen.zip" -d "$temp_download_dir"; then
        echo "Failed to extract wg-confgen."
        exit 1004 # zip-file could not be extracted
    fi

    # Move wg-confgen to /etc/wireguard
    if ! sudo mv "$temp_download_dir/wg-confgen-master/wg-confgen"/* "$varWg_confgenLocation"; then
        echo "Failed to move wg-confgen to $varWg_confgenLocation."
        exit 1005 # folder could not be moved to /etc/wireguard
    fi

    # Clean up: remove temporary download directory
    sudo rm -rf "$temp_download_dir"
fi