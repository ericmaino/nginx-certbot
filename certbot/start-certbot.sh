#!/bin/bash

FindOldCerts()
{
  DAYS=$1
  SEARCH_PATH=$2

  find ${SEARCH_PATH} -mtime +${DAYS} | grep -i \.pem  | wc -l
}

www_root=/var/www/certbot
LIVE_ROOT=/etc/letsencrypt/live

CERT_REFERSH=30
if [ -z "${CERT_REFRESH}" ]; then
  CERT_REFRESH=30
fi

echo "### Requesting Let's Encrypt certificate for ${DOMAINS} ..."
echo "Refreshing certifcates every ${CERT_REFRESH} days"

# Select appropriate email arg
case "${EMAIL}" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email ${EMAIL}" ;;
esac

# Enable staging mode if needed
if [ ${STAGING} != "0" ]; then 
  echo "  #  #  # Using CERTBOT Staging  #  #  #"
  staging_arg="--staging"; 
fi

mkdir -p ${www_root}

while :
do
  echo "Checking for old certificates . . . "

  # Certs older then 30 days
  OLD_CERT_COUNT=$(FindOldCerts ${CERT_REFRESH} ${LIVE_ROOT})

  if [ ${OLD_CERT_COUNT} -gt 0 ]; then
    echo "Old certificates detected. Attempting to renew . . . "
    certbot renew
  fi

  for domain in "${DOMAINS[@]}"; do
    CERT_ROOT="${LIVE_ROOT}/${domain}"
    OLD_CERT_COUNT=$(FindOldCerts ${CERT_REFRESH} ${CERT_ROOT})
    
    if [ ! -d ${CERT_ROOT} ] || [ ${OLD_CERT_COUNT} -gt 0 ]; then
      echo "Generating or rewnewing certs for ${domain}"
      certbot certonly -n --webroot -w ${www_root} \
          ${staging_arg} \
          ${email_arg} \
          -d ${domain} \
          --rsa-key-size ${RSA_KEY_SIZE} \
          --agree-tos \
          --force-renewal
    fi
  done

  echo "Sleeping for an hour"
  sleep 1h
done
