#!/bin/bash

# This script will allow all ports / or custom port for a specific domain name (With dynamic IP) in UFW firewall

# Move to the script directory
cd /usr/local/bin/DynamicAllowUFW

# Check if the script is run as root
if [ $EUID -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Check if the config file exists
if [ ! -f config ]; then
    echo "Config file not found"
    exit 1
fi

# Check if the IP file exists
if [ -f IP ]; then
    # Get the IP address from the file
    IP = $( cat IP )

    # Delete the IP address from the file
    echo "" > IP

    # Delete the IP address from UFW firewall
    ufw delete allow from $IP
fi

# Get the domain name from config file (without lines that contains '#' )
DOMAIN=$(cat config | grep -v "#" | grep DOMAIN | cut -d '=' -f 2)

# Check if the domain name is empty
if [ -z $DOMAIN ]; then
    echo "Domain name is empty"
    exit 1
fi

# Check if the domain name is valid
if ! host $DOMAIN > /dev/null 2>&1; then
    echo "Domain name is not valid"
    exit 1
fi

# Get the IP address of the domain name
IP=$(host $DOMAIN | grep "has address" | cut -d ' ' -f 4)

# Get port number from config file (without lines that contains '#' )
PORT=$(cat config | grep -v "#" | grep PORT | cut -d '=' -f 2)

# Check if the port number is empty elseif PORT equals any port number or the custom port number
if [ -z $PORT ] || [ $PORT = "any" ]; then
    # Allow all ports for the domain name
    ufw allow from $IP
else
    # Check if the port number is valid between 1 and 65535
    if ! [[ $PORT =~ ^[0-9]+$ ]] || [ $PORT -lt 1 ] || [ $PORT -gt 65535 ]; then
        echo "Port number is not valid"
        exit 1
    fi

    # Allow the port number for the domain name
    ufw allow from $IP to any port $PORT
fi

# Reload UFW firewall
ufw reload

# Save the IP address in a file
echo $IP > IP