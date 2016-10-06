#!/bin/bash

PROCNAME='nginx'
DAEMON='/usr/sbin/nginx'
DAEMON_ARGS=( -g "daemon off;" )

if [ -z "$1" ]; then
  set -- "${DAEMON}" "${DAEMON_ARGS[@]}"
elif [ "${1:0:1}" = '-' ]; then
  set -- "${DAEMON}" "$@"
elif [ "${1}" = "${PROCNAME}" ]; then
  shift
  set -- "${DAEMON}" "$@"
fi

if [ ! -f /etc/nginx/nginx.conf ]; then
  mkdir -p /etc/nginx
  cp -Rp /etc/nginx.default/* /etc/nginx/
fi

if [ ! -f /etc/nginx/cert.d/default.pem -o ! -f /etc/nginx/cert.d/default.key ]; then
  mkdir -p /etc/nginx/cert.d
  if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem -o ! -f /etc/ssl/private/ssl-cert-snakeoil.key ]; then
    dpkg-reconfigure ssl-cert
  fi
  cp -p /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/nginx/cert.d/default.pem
  cp -p /etc/ssl/private/ssl-cert-snakeoil.key /etc/nginx/cert.d/default.key
fi

if [ ! -f /etc/nginx/cert.d/dhparam.pem ]; then
  mkdir -p /etc/nginx/cert.d
  openssl dhparam -out /etc/nginx/cert.d/dhparam.pem 2048
fi

if [ ! `find /usr/share/nginx/html | wc -l` -gt 1 ]; then
  mkdir -p /usr/share/nginx/html
  cp -Rp /usr/share/nginx/html.default/* /usr/share/nginx/html/
fi

chown -R root:root /etc/nginx
chown -R root:root /usr/share/nginx/html

exec "$@"
