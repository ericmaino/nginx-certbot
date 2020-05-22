#!/bin/bash

CONFIG_ROOT=/etc/nginx/conf.d
CERT_ROOT=/etc/letsencrypt/live/${DOMAIN}

## Setup for challenge response
echo "
server {
    listen 80;
    server_name ${DOMAIN};
    server_tokens off;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}
" > ${CONFIG_ROOT}/app.conf
nginx


while [ ! -e "${CERT_ROOT}/fullchain.pem" ]
do
    echo "Waiting for cerificate generation"
    sleep 5s
done

if [ ! -e "${CONFIG_ROOT}/options-ssl-nginx.conf" ] || [ ! -e "${CONFIG_ROOT}/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "${CONFIG_ROOT}"
  wget -O "${CONFIG_ROOT}/options-ssl-nginx.conf" https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf 
  wget -O "${CONFIG_ROOT}/ssl-dhparams.pem" https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem 
  echo
fi

echo "
server {
    listen 80;
    server_name ${DOMAIN};
    server_tokens off;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name ${DOMAIN};
    server_tokens off;

    ssl_certificate ${CERT_ROOT}/fullchain.pem;
    ssl_certificate_key ${CERT_ROOT}/privkey.pem;
    include ${CONFIG_ROOT}/options-ssl-nginx.conf;
    ssl_dhparam ${CONFIG_ROOT}/ssl-dhparams.pem;

    location / {
        proxy_pass  ${INTERNAL_URL};
        proxy_set_header    Host                \$http_host;
        proxy_set_header    X-Real-IP           \$remote_addr;
        proxy_set_header    X-Forwarded-For     \$proxy_add_x_forwarded_for;
    }
}
#" > /etc/nginx/conf.d/app.conf

echo "#  #  #  Restarting NGINX  #  #  #"
nginx -s stop
sleep 3
nginx -g "daemon off;"