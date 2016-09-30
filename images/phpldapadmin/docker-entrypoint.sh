#!/bin/bash

[ ! -n "${LDAP_BASE_DN}"       ] && LDAP_BASE_DN=`echo "${LDAP_ENV_LDAP_DOMAIN}" | sed 's|^|dc=|;s|\.|,dc=|g;'`
[ ! -n "${LDAP_BIND_DN}"       ] && LDAP_BIND_DN="cn=admin,${LDAP_BASE_DN}"
[ ! -n "${LDAP_BIND_PASSWORD}" ] && LDAP_BIND_PASSWORD="${LDAP_ENV_LDAP_PASSWORD}"

PROCNAME='apache2'
DAEMON='/usr/sbin/apache2'
DAEMON_ARGS=( -DFOREGROUND -k start )

if [ -z "$1" ]; then
  set -- "${DAEMON}" "${DAEMON_ARGS[@]}"
elif [ "${1:0:1}" = '-' ]; then
  set -- "${DAEMON}" "$@"
elif [ "${1}" = "${PROCNAME}" ]; then
  shift
  set -- "${DAEMON}" "$@"
fi

[ ! -d /opt/phpldapadmin/config ] && mkdir -p /opt/phpldapadmin/config

if [ ! -f /opt/phpldapadmin/config/config.php ]; then
  cp -Rp /opt/phpldapadmin/config.default/* /opt/phpldapadmin/config/
fi

rm -f /run/apache2/apache2.pid

chown -R root:root /opt/phpldapadmin
chmod -R u=rwX,g=rX,o=rX /opt/phpldapadmin

. /etc/apache2/envvars
export LDAP_BASE_DN
export LDAP_BIND_DN
export LDAP_BIND_PASSWORD

exec "$@"
