#!/bin/sh

PROCNAME='docker-gen'
DAEMON='/usr/local/bin/docker-gen'

if [ -z "$1" ]; then
  set -- "${DAEMON}"
elif [ "${1:0:1}" = '-' ]; then
  set -- "${DAEMON}" "$@"
elif [ "$1" = "${PROCNAME}" ]; then
  shift
  set -- "${DAEMON}" "$@"
fi

if [ "$1" = "${DAEMON}" ]; then
  for i; do
    shift
    if [ "$previous" = '-notify-sighup' ]; then
      set -- "$@" `awk "{if (\\$2==\"$i\") print \\$3}" /etc/hosts`
    else
      set -- "$@" "$i"
    fi
    previous="$i"
  done
fi

if [ ! `find /etc/docker-gen | wc -l` -gt 1 ]; then
  mkdir -p /etc/docker-gen
  cp -Rp /etc/docker-gen.default/* /etc/docker-gen/
fi

chown -R root:root /etc/docker-gen

exec "$@"
