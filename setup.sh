#!/bin/bash

# This script will install DynamicAllowUFW.sh script and setup a cron job to run it every 10 minutes

cd dynamic-allow-ufw

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

# Ask the user to enter the domain name
read -p "Enter the domain name: " DOMAIN

# Check if the domain name is empty
if [ -z $DOMAIN ]; then
    echo "Domain name is empty"
    exit 1
fi

# Save the domain name in config file
echo "DOMAIN=$DOMAIN" > config

# Ask the user to enter the port number
read -p "Enter the port number (leave empty for any port): " PORT

# Check if the port number is empty
if [ -z $PORT ]; then
    # Save the port number in config file
    echo "PORT=any" >> config
else
    # Check if the port number is valid between 1 and 65535
    if ! [[ $PORT =~ ^[0-9]+$ ]] || [ $PORT -lt 1 ] || [ $PORT -gt 65535 ]; then
        echo "Port number is not valid"
        exit 1
    fi

    # Save the port number in config file
    echo "PORT=$PORT" >> config
fi

# Copy the script folder to /usr/local/bin
cp -r ../dynamic-allow-ufw/ /usr/local/bin

# Create a cron job to run the script every 10 minutes
echo "*/10 * * * * root /usr/local/bin/dynamic-allow-ufw/DynamicAllowUFW.sh" > /etc/cron.d/DynamicAllowUFW

# Allow script to be executed
chmod +x /usr/local/bin/dynamic-allow-ufw/DynamicAllowUFW.sh.sh

# Reload cron daemon
/etc/init.d/cron reload