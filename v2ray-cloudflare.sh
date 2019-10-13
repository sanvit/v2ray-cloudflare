#!/bin/bash

# root permission check
[[ $(id -u) != 0 ]] && echo -e "\n Please run as root. e.g. sudo bash <(curl -L -s https://sanvit.me/v2ray-cloudflare.sh)" && exit 1

# create random data
uuid=$(cat /proc/sys/kernel/random/uuid)
port=$(shuf -i20001-65535 -n1)

# remove and install softwares as needed
apt -y remove apache* postfix
apt update
apt -y upgrade
apt -y install nginx git vim wget openssl unzip
apt -y autoremove

# generate SSL certificate
mkdir -p /var/certs
openssl req -x509 -newkey rsa:2048 -keyout /var/certs/key.pem -out /var/certs/cert.pem -days 3650 -nodes -subj "/C=KR/ST=Seoul/L=Seoul/O=Security/OU=Security/CN=v2ray"

# install v2ray
echo -e "Installing v2ray..."
bash <(curl -L -s https://install.direct/go.sh) 1> /dev/null

# download pre-configured settings
git clone https://github.com/sanvit/v2ray-cloudflare tmp --depth 1

# change to random data for security reasons
sed "s/44444/${port}/g" tmp/nginx-config.conf > /etc/nginx/sites-available/default
sed -e "s/44444/${port}/g" -e "s/uuid/${uuid}/g" tmp/v2ray-config.json > /etc/v2ray/config.json

# remove temporary files
rm -rf tmp

# restart services to apply new configurations
service nginx restart
service v2ray restart

echo -e "\n Install Finished! \n\n ID : $uuid"
