#!/bin/bash

# source $(which logshell)
# run this script in nginxgen docker.
# need to buy to main and assign it to your IP first

echo "Run apt update and install python modules..."
apt update
apt install python3 python3-venv libaugeas0

echo "Setup python env..."
python3 -m venv /opt/certbot/
/opt/certbot/bin/pip install --upgrade pip

echo "Install certbot..."
/opt/certbot/bin/pip install certbot certbot-nginx
ln -s /opt/certbot/bin/certbot /usr/bin/certbot

echo "Ready to create certificate:"
certbot certonly --nginx

echo "Create crontab to auto update certificate."
echo "0 0,12 * * * root /opt/certbot/bin/python -c 'import random; import time; time.sleep(random.random() * 3600)' && sudo certbot renew -q" | sudo tee -a /etc/crontab >/dev/null

echo "Auto upgrade certbot monthly."
/opt/certbot/bin/pip install --upgrade certbot certbot-nginx

echo "Create symlink of cert in nginx cert folder..."
ln -sn /etc/letsencrypt/live/lonelylucifer.site/cert.pem /etc/nginx/certs/letencrypt.crt
ln -sn /etc/letsencrypt/live/lonelylucifer.site/privkey.pem /etc/nginx/certs/letencrypt.key

## manual add cert to nginx.
