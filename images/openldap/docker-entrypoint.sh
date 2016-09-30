#!/bin/bash

[ ! -n "${LDAP_DOMAIN}"       ] && echo "Error: LDAP_DOMAIN must be set" && exit 1
[ ! -n "${LDAP_PASSWORD}"     ] && echo "Error: LDAP_PASSWORD must be set" && exit 1

[ ! -n "${LDAP_BASE_DN}"      ] && LDAP_BASE_DN=`echo "${LDAP_DOMAIN}" | sed 's|^|dc=|;s|\.|,dc=|g;'`
[ ! -n "${LDAP_LOG_LEVEL}"    ] && LDAP_LOG_LEVEL=0
[ ! -n "${LDAP_ORGANIZATION}" ] && LDAP_ORGANIZATION="${LDAP_DOMAIN}" 

PROCNAME='slapd'
DAEMON='/usr/sbin/slapd'
DAEMON_ARGS=( -h 'ldapi:/// ldaps:// ldap://' -u 'openldap' -g 'openldap' -d "${LDAP_LOG_LEVEL}" )

if [ -z "$1" ]; then
  set -- "${DAEMON}" "${DAEMON_ARGS[@]}"
elif [ "${1:0:1}" = '-' ]; then
  set -- "${DAEMON}" "$@"
elif [ "${1}" = "${PROCNAME}" ]; then
  shift
  set -- "${DAEMON}" "$@"
fi

[ ! -d /etc/ldap/slapd.d ] && mkdir -p /etc/ldap/slapd.d
[ ! -d /var/lib/ldap     ] && mkdir -p /var/lib/ldap

if [ ! -f '/etc/ldap/slapd.d/cn=config.ldif' -a ! -f '/var/lib/ldap/data.mdb' ]; then
  for schema_file in /etc/ldap/schema/*.schema; do
    schema_ldif=`echo "${schema_file}" | sed 's|\.schema$|.ldif|;'`
    [ ! -f "${schema_ldif}" ] && schema2ldif "${schema_file}" > "${schema_ldif}"
  done

  cat <<EOF | debconf-set-selections
slapd shared/organization string ${LDAP_ORGANIZATION}
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/domain string ${LDAP_DOMAIN}
slapd slapd/dump_database select when needed
slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
slapd slapd/internal/adminpw password ${LDAP_PASSWORD}
slapd slapd/internal/generated_adminpw password ${LDAP_PASSWORD}
slapd slapd/move_old_database boolean true
slapd slapd/no_configuration boolean false
slapd slapd/password1 password ${LDAP_PASSWORD}
slapd slapd/password2 password ${LDAP_PASSWORD}
slapd slapd/purge_database boolean true
EOF
  dpkg-reconfigure -f noninteractive slapd
fi

chown -R openldap:openldap /etc/ldap/slapd.d
chown -R openldap:openldap /var/lib/ldap
ulimit -n 1024

exec "$@"
