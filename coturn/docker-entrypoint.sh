#!/bin/bash

[ ! -n "${LDAP_BASE_DN}"       ] && LDAP_BASE_DN=`echo "${LDAP_ENV_LDAP_DOMAIN}" | sed 's|^|dc=|;s|\.|,dc=|g;'`
[ ! -n "${LDAP_BIND_DN}"       ] && LDAP_BIND_DN="cn=admin,${LDAP_BASE_DN}"
[ ! -n "${LDAP_BIND_PASSWORD}" ] && LDAP_BIND_PASSWORD="${LDAP_ENV_LDAP_PASSWORD}"
[ ! -n "${SIP_DOMAIN}"         ] && SIP_DOMAIN="${LDAP_ENV_LDAP_DOMAIN}"

PROCNAME='turnserver'
USER='turnserver'
DAEMON='/usr/bin/turnserver'
DAEMON_ARGS=( -c '/etc/coturn/turnserver.conf' -v )

if [ -z "$1" ]; then
  set -- "${DAEMON}" "${DAEMON_ARGS[@]}"
elif [ "${1:0:1}" = '-' ]; then
  set -- "${DAEMON}" "$@"
elif [ "${1}" = "${PROCNAME}" ]; then
  shift
  set -- "${DAEMON}" "$@"
fi

if [ ! -f /etc/coturn/coturn.conf ]; then
  cp -Rp /etc/coturn.default/* /etc/coturn/
fi

if [ -z "${SKIP_AUTO_IP}" -a -z "${EXTERNAL_IP}" ]; then
  if [ -n "${USE_IPV4}" ]; then
    EXTERNAL_IP=`curl -4 icanhazip.com 2> /dev/null`
  else
    EXTERNAL_IP=`curl icanhazip.com 2> /dev/null`
  fi
fi

if [ -n "${EXTERNAL_IP}" ]; then
  sed -i "s|^external-ip=.*|external-ip=${EXTERNAL_IP}|;" /etc/coturn/turnserver.conf
fi
if [ -n "${SIP_DOMAIN}" ]; then
  sed -i "s|^realm=.*|realm=${SIP_DOMAIN}|;" /etc/coturn/turnserver.conf
fi

export LDAP_BASE_DN
export LDAP_BIND_DN
export LDAP_BIND_PASSWORD

if [ "$1" = "${DAEMON}" -a `id -u` = '0' ]; then
  exec gosu "${USER}" "$@"
fi

exec "$@"
